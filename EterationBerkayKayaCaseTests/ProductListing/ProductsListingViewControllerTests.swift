//
//  ProductsListingViewControllerTests.swift
//  EterationBerkayKayaCaseTests
//
//  Created by Berkay on 20.08.2025.
//

import XCTest
@testable import EterationBerkayKayaCase

final class ProductsListingViewControllerTests: XCTestCase {
    
    // MARK: - Properties
    var viewController: ProductsListingViewController!
    var mockViewModel: MockProductsListingViewModel!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockViewModel = MockProductsListingViewModel()
        viewController = ProductsListingViewController(viewModel: mockViewModel)
        _ = viewController.view
    }
    
    override func tearDown() {
        viewController = nil
        mockViewModel = nil
        super.tearDown()
    }
    
    // MARK: - View Lifecycle Tests
    func testViewDidLoad() {
        viewController.viewDidLoad()
        XCTAssertTrue(mockViewModel.didLoadCalled)
        XCTAssertNotNil(viewController.view.subviews.first { $0 is UISearchBar })
        XCTAssertNotNil(viewController.navigationItem.leftBarButtonItem)
    }
    
    // MARK: - UI Components Tests
    func testSearchBarConfiguration() {
        viewController.viewDidLoad()
        let searchBar = viewController.view.subviews.first { $0 is UISearchBar } as? UISearchBar
        
        XCTAssertNotNil(searchBar)
        XCTAssertEqual(searchBar?.placeholder, "Search")
        XCTAssertEqual(searchBar?.searchBarStyle, .minimal)
        XCTAssertNotNil(searchBar?.delegate)
    }
    
    // MARK: - CollectionView DataSource Tests
    func testCollectionViewNumberOfItems() {
        mockViewModel.mockNumberOfItems = 5
        viewController.viewDidLoad()
        
        let collectionView = viewController.view.subviews.first { $0 is UICollectionView } as! UICollectionView
        let numberOfItems = viewController.collectionView(collectionView, numberOfItemsInSection: 0)
        XCTAssertEqual(numberOfItems, 5)
    }
    
    func testCollectionViewCellForItemAt() {
        let mockProduct = createMockProduct()
        mockViewModel.mockProduct = mockProduct
        viewController.viewDidLoad()
        
        let collectionView = viewController.view.subviews.first { $0 is UICollectionView } as! UICollectionView
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = viewController.collectionView(collectionView, cellForItemAt: indexPath)
        
        XCTAssertTrue(cell is ProductCollectionViewCell)
        XCTAssertTrue(mockViewModel.getProductAtCalled)
    }
    
    func testCollectionViewDidSelectItem() {
        let mockProduct = createMockProduct()
        mockViewModel.mockProduct = mockProduct
        mockViewModel.mockNumberOfItems = 1
        
        _ = UINavigationController(rootViewController: viewController)
        viewController.viewDidLoad()
        
        let collectionView = viewController.view.subviews.first { $0 is UICollectionView } as! UICollectionView
        let indexPath = IndexPath(row: 0, section: 0)
        
        viewController.collectionView(collectionView, didSelectItemAt: indexPath)
        
        XCTAssertTrue(mockViewModel.getProductAtCalled)
    }

    
    // MARK: - SearchBar Delegate Tests
    func testSearchBarTextDidChange() {
        viewController.viewDidLoad()
        let searchBar = viewController.view.subviews.first { $0 is UISearchBar } as! UISearchBar
        viewController.searchBar(searchBar, textDidChange: "iPhone")
        let expectation = XCTestExpectation(description: "Search debounce")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockViewModel.searchProductsCalled)
    }
    
    func testSearchBarTextDidChange_EmptyText() {
        viewController.viewDidLoad()
        let searchBar = viewController.view.subviews.first { $0 is UISearchBar } as! UISearchBar
        viewController.searchBar(searchBar, textDidChange: "")
        
        XCTAssertTrue(mockViewModel.clearAllFiltersAndSearchCalled)
    }
    
    func testSearchBarTextDidChange_ShortText() {
        viewController.viewDidLoad()
        let searchBar = viewController.view.subviews.first { $0 is UISearchBar } as! UISearchBar
        
        viewController.searchBar(searchBar, textDidChange: "a")
        
        let expectation = XCTestExpectation(description: "Short search")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        XCTAssertFalse(mockViewModel.searchProductsCalled)
    }
    
    func testSearchBarSearchButtonClicked() {
        viewController.viewDidLoad()
        let searchBar = viewController.view.subviews.first { $0 is UISearchBar } as! UISearchBar
        searchBar.text = "iPhone"
        viewController.searchBarSearchButtonClicked(searchBar)
        XCTAssertTrue(mockViewModel.searchProductsCalled)
    }
    
    func testSearchBarCancelButtonClicked() {
        viewController.viewDidLoad()
        let searchBar = viewController.view.subviews.first { $0 is UISearchBar } as! UISearchBar
        viewController.searchBarCancelButtonClicked(searchBar)
        XCTAssertEqual(searchBar.text, "")
        XCTAssertTrue(mockViewModel.clearAllFiltersAndSearchCalled)
    }
    
    func testSearchBarTextDidBeginEditing() {
        viewController.viewDidLoad()
        let searchBar = viewController.view.subviews.first { $0 is UISearchBar } as! UISearchBar
        viewController.searchBarTextDidBeginEditing(searchBar)
        XCTAssertTrue(searchBar.showsCancelButton)
    }
    
    func testSearchBarTextDidEndEditing() {
        viewController.viewDidLoad()
        let searchBar = viewController.view.subviews.first { $0 is UISearchBar } as! UISearchBar
        searchBar.setShowsCancelButton(true, animated: false)
        viewController.searchBarTextDidEndEditing(searchBar)
        XCTAssertFalse(searchBar.showsCancelButton)
    }
    
    
    // MARK: - ProductCollectionViewCellDelegate Tests
    func testProductCellDidTapFavorite() {
        let mockProduct = createMockProduct()
        viewController.viewDidLoad()
        let mockCell = ProductCollectionViewCell()
        viewController.productCellDidTapFavorite(mockCell, product: mockProduct)
        XCTAssertTrue(mockViewModel.toggleFavoriteCalled)
    }
    
    func testProductCellDidTapAddToCart() {
        let mockProduct = createMockProduct()
        viewController.viewDidLoad()
        let mockCell = ProductCollectionViewCell()
        viewController.productCellDidTapAddToCart(mockCell, product: mockProduct)
        XCTAssertTrue(mockViewModel.addToCartCalled)
    }
    
    // MARK: - ViewModel Callbacks Tests
    func testViewModelReloadDataCallback() {
        viewController.viewDidLoad()
        
        let collectionView = viewController.view.subviews.first { $0 is UICollectionView } as! UICollectionView
        let initialContentOffset = collectionView.contentOffset
        mockViewModel.reloadData?()
        XCTAssertNotNil(mockViewModel.reloadData)
    }
    
    func testViewModelShowEmptyStateCallback() {
        viewController.viewDidLoad()
        mockViewModel.showEmptyState?("Test empty message")
        XCTAssertNotNil(mockViewModel.showEmptyState)
    }
    
    func testViewModelHideEmptyStateCallback() {
        viewController.viewDidLoad()
        mockViewModel.hideEmptyState?()
        XCTAssertNotNil(mockViewModel.hideEmptyState)
    }
    
    // MARK: - Helper Methods
    private func createMockProduct() -> Product {
        return Product(
            createdAt: "2024-01-01T00:00:00Z",
            name: "Test Product",
            image: "test.jpg",
            price: "100",
            description: "Test description",
            model: "Test Model",
            brand: "Test Brand",
            id: "test-id"
        )
    }
}

// MARK: - Mock ViewModel
class MockProductsListingViewModel: ProductsListingViewModel {
    
    // MARK: - Call Tracking
    var didLoadCalled = false
    var loadMoreIfNeededCalled = false
    var searchProductsCalled = false
    var clearAllFiltersAndSearchCalled = false
    var getProductAtCalled = false
    var addToCartCalled = false
    var toggleFavoriteCalled = false
    
    // MARK: - Mock Properties
    var mockNumberOfItems = 0
    var mockProduct: Product?
    
    override var numberOfItems: Int {
        return mockNumberOfItems
    }
    
    override func didLoad() {
        didLoadCalled = true
        super.didLoad()
    }
    
    override func loadMoreIfNeeded(currentIndex: Int) {
        loadMoreIfNeededCalled = true
    }
    
    override func getProductAt(index: Int) -> Product {
        getProductAtCalled = true
        return mockProduct ?? Product(createdAt: nil, name: "Default", image: nil, price: "0", description: nil, model: nil, brand: nil, id: "default")
    }
    
    override func getAllProducts() -> [Product] {
        return mockProduct != nil ? [mockProduct!] : []
    }
    
    override func searchProducts(with searchText: String) {
        searchProductsCalled = true
    }
    
    override func clearAllFiltersAndSearch() {
        clearAllFiltersAndSearchCalled = true
    }
    
    override func toggleFavorite(product: Product?) {
        toggleFavoriteCalled = true
    }
    
    override func addToCart(product: Product?) {
        addToCartCalled = true
    }
}
