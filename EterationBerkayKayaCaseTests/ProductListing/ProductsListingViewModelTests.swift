//
//  ProductsListingViewModelTests.swift
//  EterationBerkayKayaCaseTests
//
//  Created by Berkay on 20.08.2025.
//

import XCTest
@testable import EterationBerkayKayaCase

final class ProductsListingViewModelTests: XCTestCase {
    
    // MARK: - Properties
    var viewModel: ProductsListingViewModel!
    var mockRepository: MockProductsRepository!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockProductsRepository()
        viewModel = ProductsListingViewModel(productRepository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    func testInitialState() {
        XCTAssertEqual(viewModel.numberOfItems, 0)
        XCTAssertEqual(viewModel.getAllProducts().count, 0)
        let (sortType, brands, models) = viewModel.getCurrentFilterState()
        XCTAssertEqual(sortType, .none)
        XCTAssertTrue(brands.isEmpty)
        XCTAssertTrue(models.isEmpty)
    }
    
    // MARK: - Data Loading Tests
    func testDidLoad_Success() {
        let mockProducts = createMockProducts()
        mockRepository.mockProducts = mockProducts
        
        var reloadDataCalled = false
        var hideLoadingCalled = false
        
        viewModel.reloadData = { reloadDataCalled = true }
        viewModel.hideLoading = { hideLoadingCalled = true }
        
        viewModel.didLoad()
        
        XCTAssertTrue(reloadDataCalled)
        XCTAssertTrue(hideLoadingCalled)
        XCTAssertEqual(viewModel.numberOfItems, 4) // itemsPerPage = 4
        XCTAssertEqual(viewModel.getAllProducts().count, 6)
    }
    
    func testDidLoad_Failure() {
        mockRepository.shouldReturnError = true
        
        var showErrorCalled = false
        var showEmptyStateCalled = false
        var hideLoadingCalled = false
        
        viewModel.showError = { _ in showErrorCalled = true }
        viewModel.showEmptyState = { _ in showEmptyStateCalled = true }
        viewModel.hideLoading = { hideLoadingCalled = true }
        
        viewModel.didLoad()
        
        XCTAssertTrue(showErrorCalled)
        XCTAssertTrue(showEmptyStateCalled)
        XCTAssertTrue(hideLoadingCalled)
        XCTAssertEqual(viewModel.numberOfItems, 0)
    }
    
    // MARK: - Pagination Tests
    func testLoadMoreIfNeeded() {
        let mockProducts = createMockProducts()
        mockRepository.mockProducts = mockProducts
        viewModel.didLoad()
        
        var insertNewItemsCalled = false
        viewModel.insertNewItems = { _ in insertNewItemsCalled = true }
        
        viewModel.loadMoreIfNeeded(currentIndex: 2)
        
        let expectation = XCTestExpectation(description: "Pagination")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(insertNewItemsCalled)
        XCTAssertEqual(viewModel.numberOfItems, 6)
    }
    
    // MARK: - Search Tests
    func testSearchProducts() {
        let mockProducts = createMockProducts()
        mockRepository.mockProducts = mockProducts
        viewModel.didLoad()
        
        var reloadDataCalled = false
        viewModel.reloadData = { reloadDataCalled = true }
        
        viewModel.searchProducts(with: "iPhone")
        
        let expectation = XCTestExpectation(description: "Search")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        XCTAssertTrue(reloadDataCalled)
        XCTAssertEqual(viewModel.numberOfItems, 2)
    }
    
    func testSearchProducts_EmptyResult() {
        let mockProducts = createMockProducts()
        mockRepository.mockProducts = mockProducts
        viewModel.didLoad()
        var showEmptyStateCalled = false
        viewModel.showEmptyState = { _ in showEmptyStateCalled = true }
        viewModel.searchProducts(with: "NonExistent")
        
        let expectation = XCTestExpectation(description: "Search")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        XCTAssertTrue(showEmptyStateCalled)
        XCTAssertEqual(viewModel.numberOfItems, 0)
    }
    
    func testClearAllFiltersAndSearch() {
        let mockProducts = createMockProducts()
        mockRepository.mockProducts = mockProducts
        viewModel.didLoad()
        
        viewModel.searchProducts(with: "iPhone")
        
        var reloadDataCalled = false
        viewModel.reloadData = { reloadDataCalled = true }
        
        viewModel.clearAllFiltersAndSearch()
        
        XCTAssertTrue(reloadDataCalled)
        XCTAssertEqual(viewModel.numberOfItems, 4)
        
        let (sortType, brands, models) = viewModel.getCurrentFilterState()
        XCTAssertEqual(sortType, .none)
        XCTAssertTrue(brands.isEmpty)
        XCTAssertTrue(models.isEmpty)
    }
    
    // MARK: - Add to Cart Tests
    func testAddToCart_Success() {
        let product = createMockProducts().first!
        var addToCartSuccessCalled = false
        viewModel.addToCartSuccess = { _ in addToCartSuccessCalled = true }
        viewModel.addToCart(product: product)
        XCTAssertTrue(addToCartSuccessCalled)
    }
    
    func testAddToCart_NilProduct() {
        var addToCartFailureCalled = false
        viewModel.addToCartFailure = { _ in addToCartFailureCalled = true }
        viewModel.addToCart(product: nil)
        XCTAssertTrue(addToCartFailureCalled)
    }
    
    // MARK: - Toggle Favorite Tests
    func testToggleFavorite_Success() {
        let product = createMockProducts().first!
        var favoriteToggleSuccessCalled = false
        viewModel.favoriteToggleSuccess = { _ in favoriteToggleSuccessCalled = true }
    
        viewModel.toggleFavorite(product: product)
        XCTAssertTrue(favoriteToggleSuccessCalled)
    }
    
    func testToggleFavorite_NilProduct() {
        var favoriteToggleFailureCalled = false
        viewModel.favoriteToggleFailure = { _ in favoriteToggleFailureCalled = true }

        viewModel.toggleFavorite(product: nil)
        XCTAssertTrue(favoriteToggleFailureCalled)
    }
    
    // MARK: - Helper Methods
    private func createMockProducts() -> [Product] {
        return [
            Product(
                createdAt: "2024-01-01T00:00:00Z",
                name: "iPhone 14",
                image: "image1.jpg",
                price: "1000",
                description: "Latest iPhone",
                model: "14",
                brand: "Apple",
                id: "1"
            ),
            Product(
                createdAt: "2024-01-02T00:00:00Z",
                name: "iPhone 15",
                image: "image2.jpg",
                price: "1200",
                description: "Newest iPhone",
                model: "15",
                brand: "Apple",
                id: "2"
            ),
            Product(
                createdAt: "2024-01-03T00:00:00Z",
                name: "Samsung Galaxy S24",
                image: "image3.jpg",
                price: "900",
                description: "Latest Samsung",
                model: "S24",
                brand: "Samsung",
                id: "3"
            ),
            Product(
                createdAt: "2024-01-04T00:00:00Z",
                name: "MacBook Pro",
                image: "image4.jpg",
                price: "2000",
                description: "Powerful laptop",
                model: "Pro",
                brand: "Apple",
                id: "4"
            ),
            Product(
                createdAt: "2024-01-05T00:00:00Z",
                name: "iPad Air",
                image: "image5.jpg",
                price: "500",
                description: "Lightweight tablet",
                model: "Air",
                brand: "Apple",
                id: "5"
            ),
            Product(
                createdAt: "2024-01-06T00:00:00Z",
                name: "Samsung Tab",
                image: "image6.jpg",
                price: "400",
                description: "Android tablet",
                model: "Tab",
                brand: "Samsung",
                id: "6"
            )
        ]
    }
}

// MARK: - Mock Repository
class MockProductsRepository: ProductsRepositoryProtocol {
    
    var mockProducts: [Product] = []
    var shouldReturnError = false
    
    func getProducts(completion: @escaping (Result<[Product], NetworkError>) -> Void) {
        if shouldReturnError {
            let error = NetworkError.badRequest
            completion(.failure(error))
        } else {
            completion(.success(mockProducts))
        }
    }
}
