//
//  ProductsListingViewModel.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation

protocol ProductListingDataSource {
    var numberOfItems: Int { get }
    
    func cellForItemAt(indexPath: IndexPath) -> ProductCollectionViewCellProtocol
    func didLoad()
    func loadMoreIfNeeded(currentIndex: Int)
    func getProductAt(index: Int) -> Product
    func getAllProducts() -> [Product]
    func getCurrentFilterState() -> (SortType, Set<String>, Set<String>)
    func applyFilters(sortType: SortType, selectedBrands: Set<String>, selectedModels: Set<String>)
    func searchProducts(with searchText: String)
    func clearAllFiltersAndSearch()
    func toggleFavorite(product: Product?)
}

protocol ProductListingEventSource {
    var reloadData: VoidClosure? { get }
    var insertNewItems: IndexPathClosure? { get }
    var showLoadingMore: VoidClosure? { get }
    var hideLoadingMore: VoidClosure? { get }
    var showError: ((String) -> Void)? { get }
    var showEmptyState: StringClosure? { get }
    var hideEmptyState: VoidClosure? { get }
    var addToCartSuccess: StringClosure? { get }
    var addToCartFailure: StringClosure? { get }
    var favoriteToggleSuccess: StringClosure? { get }
    var favoriteToggleFailure: StringClosure? { get }
}

protocol ProductsListingProtocol: ProductListingDataSource, ProductListingEventSource {}


class ProductsListingViewModel: BaseViewModel, ProductsListingProtocol {
    
    // MARK: - EventSource Properties
    var reloadData: VoidClosure?
    var insertNewItems: IndexPathClosure?
    var showLoadingMore: VoidClosure?
    var hideLoadingMore: VoidClosure?
    var showError: StringClosure?
    var showEmptyState: StringClosure?
    var hideEmptyState: VoidClosure?
    var addToCartSuccess: StringClosure?
    var addToCartFailure: StringClosure?
    var favoriteToggleSuccess: StringClosure?
    var favoriteToggleFailure: StringClosure?
    
    // MARK: - DataSource Properties
    var numberOfItems: Int {
       return cellItems.count
    }
    
    func cellForItemAt(indexPath: IndexPath) -> ProductCollectionViewCellProtocol {
      return cellItems[indexPath.row]
    }
    
    func getAllProducts() -> [Product] {
        return allProducts
    }
    
    func getCurrentFilterState() -> (SortType, Set<String>, Set<String>) {
        return (currentSortType, currentSelectedBrands, currentSelectedModels)
    }
    
    // MARK: - Private Properties
    private var cellItems: [ProductCollectionViewCellProtocol] = []
    private var allProducts: [Product] = []
    private var productRepository: ProductsRepositoryProtocol
    private var currentFilteredProducts: [Product]?
    private func getActiveProducts() -> [Product] {
        return currentFilteredProducts ?? allProducts
    }
    private var currentSortType: SortType = .none
    private var currentSelectedBrands: Set<String> = []
    private var currentSelectedModels: Set<String> = []
    
    // Pagination properties
    private let itemsPerPage = 4
    private var currentPage = 0
    private var isLoading = false
    private var hasMoreData = true
    private var isEmpty: Bool {
        return cellItems.isEmpty
    }
    
    // DispatchQueue properties
    private var isSearching = false
    private let searchQueue = DispatchQueue(label: "search.queue", qos: .userInitiated)
    
    
    // MARK: - Initialization
    init(productRepository: ProductsRepositoryProtocol = ProductsRepository(productService: ProductService())) {
        self.productRepository = productRepository
        super.init()
    }
    
    func didLoad() {
        showLoading?()
        isLoading = true
        productRepository.getProducts { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                self.allProducts = response
                self.loadFirstPage()
                self.hideLoading?()
            case .failure(let error):
                self.hideLoading?()
                showEmptyState?(getEmptyStateMessage())
                self.showError?(error.localizedDescription)
            }
        }
    }
    
    func loadMoreIfNeeded(currentIndex: Int) {
        let threshold = cellItems.count - 2
        if currentIndex >= threshold && !isLoading && hasMoreData {
            loadNextPage()
        }
    }
    
    func getProductAt(index: Int) -> Product {
        let currentPageProducts = getCurrentPageProducts()
        return currentPageProducts[index]
    }
    
    func applyFilters(sortType: SortType, selectedBrands: Set<String>, selectedModels: Set<String>) {
        currentSortType = sortType
        currentSelectedBrands = selectedBrands
        currentSelectedModels = selectedModels
        
        var filteredProducts = allProducts
        
        if !selectedBrands.isEmpty {
            filteredProducts = filteredProducts.filter { product in
                guard let brand = product.brand else { return false }
                return selectedBrands.contains(brand)
            }
        }
        
        if !selectedModels.isEmpty {
            filteredProducts = filteredProducts.filter { product in
                guard let model = product.model else { return false }
                return selectedModels.contains(model)
            }
        }
        
        switch sortType {
        case .oldToNew:
            filteredProducts.sort { (product1, product2) in
                guard let date1 = product1.createdAt, let date2 = product2.createdAt else { return false }
                return date1 < date2
            }
        case .newToOld:
            filteredProducts.sort { (product1, product2) in
                guard let date1 = product1.createdAt, let date2 = product2.createdAt else { return false }
                return date1 > date2
            }
        case .priceHighToLow:
            filteredProducts.sort { (product1, product2) in
                guard let price1 = Double(product1.price ?? "0"),
                      let price2 = Double(product2.price ?? "0") else { return false }
                return price1 > price2
            }
        case .priceLowToHigh:
            filteredProducts.sort { (product1, product2) in
                guard let price1 = Double(product1.price ?? "0"),
                      let price2 = Double(product2.price ?? "0") else { return false }
                return price1 < price2
            }
        case .none:
           break
        }
        applyFilteredProducts(filteredProducts)
    }
    
    func searchProducts(with searchText: String) {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !isSearching else { return }
        if trimmedSearchText.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.clearAllFiltersAndSearch()
            }
            return
        }
        
        isSearching = true
        searchQueue.async { [weak self] in
            guard let self = self else { return }
            
            let searchedProducts = self.performSearch(with: trimmedSearchText)
            DispatchQueue.main.async {
                self.isSearching = false
                self.applyFilteredProducts(searchedProducts)
            }
        }
    }
    
    func clearAllFiltersAndSearch() {
        isSearching = false
        clearFilters()
        currentFilteredProducts = nil
        loadFirstPage()
    }
    
    func addToCart(product: Product?) {
        guard let product = product else {
            addToCartFailure?("Product information not available")
            return
        }
        
        BasketService.shared.addToBasket(product: product) { [weak self] result in
                switch result {
                case .success:
                    let productName = product.name ?? "Product"
                    self?.addToCartSuccess?(productName)
                    
                case .failure(let error):
                    self?.addToCartFailure?(error.localizedDescription)
                }
        }
    }
    
    func toggleFavorite(product: Product?) {
        guard let product = product,
              let productId = product.id else {
            favoriteToggleFailure?("Product information not available")
            return
        }
        
        let wasInFavorites = FavoriteService.shared.isProductInFavorites(productId: productId)
        
        FavoriteService.shared.toggleFavorite(product: product)
        let productName = product.name ?? "Product"
        let message = wasInFavorites ?
            "\(productName) removed from favorites" :
            "\(productName) added to favorites! ⭐"
        favoriteToggleSuccess?(message)
    }
}

// MARK: - Private Methods
private extension ProductsListingViewModel {
    
    private func loadFirstPage() {
        currentPage = 0
        let activeProducts = getActiveProducts()
    
        guard !activeProducts.isEmpty else {
               cellItems = []
               hasMoreData = false
               showEmptyState?(getEmptyStateMessage())
               reloadData?()
               return
           }
        
        hideEmptyState?()
        hasMoreData = activeProducts.count > itemsPerPage
         
         let endIndex = min(itemsPerPage, activeProducts.count)
         let firstPageProducts = Array(activeProducts[0..<endIndex])
         
         cellItems = firstPageProducts.map { product in
             return ProductCollectionViewCellModel(price: product.price, productName: product.name)
         }
         reloadData?()
     }
    
    private func loadNextPage() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        showLoadingMore?()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.processNextPage()
        }
    }
    
    private func processNextPage() {
         currentPage += 1
         let activeProducts = getActiveProducts()
         let startIndex = currentPage * itemsPerPage
         let endIndex = min(startIndex + itemsPerPage, activeProducts.count)
         
         guard startIndex < activeProducts.count else {
             hasMoreData = false
             isLoading = false
             hideLoadingMore?()
             return
         }
         
         let nextPageProducts = Array(activeProducts[startIndex..<endIndex])
         let startInsertIndex = cellItems.count
         
         let newCellItems = nextPageProducts.map { product in
             return ProductCollectionViewCellModel(price: product.price, productName: product.name)
         }
         
         cellItems.append(contentsOf: newCellItems)
         
         let newIndexPaths = (startInsertIndex..<cellItems.count).map { IndexPath(row: $0, section: 0) }
         
         hasMoreData = endIndex < activeProducts.count
         isLoading = false
         hideLoadingMore?()
         insertNewItems?(newIndexPaths)
     }
    
    private func getEmptyStateMessage() -> String {
         if currentFilteredProducts != nil {
             return "No products were found that match your search criteria.\nChange the filters and try again."
         } else {
             return "There are no products yet.\nCheck back later"
         }
     }
    
    private func getCurrentPageProducts() -> [Product] {
         let activeProducts = getActiveProducts()
         let startIndex = 0
         let endIndex = min(cellItems.count, activeProducts.count)
         return Array(activeProducts[startIndex..<endIndex])
     }
    
    private func performSearch(with searchText: String) -> [Product] {
        let lowercasedSearch = searchText.lowercased()
        
        return allProducts.filter { product in
            let productName = (product.name ?? "").lowercased()
            return productName.contains(lowercasedSearch)
        }
    }
    
    private func clearFilters() {
        currentSortType = .none
        currentSelectedBrands = []
        currentSelectedModels = []
    }
    
    private func applyFilteredProducts(_ products: [Product]) {
        currentFilteredProducts = products
        currentPage = 0
        cellItems.removeAll()
        
        guard !products.isEmpty else {
              hasMoreData = false
              showEmptyState?("Aradığınız kriterlere uygun ürün bulunamadı.\nFiltreleri değiştirip tekrar deneyin.")
              reloadData?()
              return
          }
          
        hideEmptyState?()
        
        hasMoreData = products.count > itemsPerPage
        let endIndex = min(itemsPerPage, products.count)
        let firstPageProducts = Array(products[0..<endIndex])
        
        cellItems = firstPageProducts.map { product in
            return ProductCollectionViewCellModel(price: product.price, productName: product.name)
        }
        reloadData?()
    }
}
