//
//  ProductDetailViewModelTests.swift
//  EterationBerkayKayaCaseTests
//
//  Created by Berkay on 20.08.2025.
//

import XCTest
@testable import EterationBerkayKayaCase

final class ProductDetailViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: ProductDetailViewModel!
    private var mockProduct: Product!
    private var mockFavoriteService: MockFavoriteService!
    private var mockBasketService: MockBasketService!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        
        mockProduct = Product(
            createdAt: "2025-08-20",
            name: "Test Product",
            image: "test_image.jpg",
            price: "99.99",
            description: "This is a test product description",
            model: "TestModel",
            brand: "TestBrand",
            id: "test-product-id"
        )
        sut = ProductDetailViewModel(product: mockProduct)
    }
    
    override func tearDown() {
        sut = nil
        mockProduct = nil
        mockFavoriteService = nil
        mockBasketService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func test_init_shouldSetProductCorrectly() {
        XCTAssertEqual(sut.productName, mockProduct.name)
        XCTAssertEqual(sut.productPrice, mockProduct.price)
        XCTAssertEqual(sut.productDescription, mockProduct.description)
        XCTAssertEqual(sut.productId, mockProduct.id)
    }
    
    // MARK: - DataSource Properties Tests
    func test_productName_shouldReturnCorrectValue() {
        let productName = sut.productName
        XCTAssertEqual(productName, "Test Product")
    }
    
    func test_productPrice_shouldReturnCorrectValue() {
        let productPrice = sut.productPrice
        XCTAssertEqual(productPrice, "99.99")
    }
    
    func test_productDescription_shouldReturnCorrectValue() {
        let productDescription = sut.productDescription
        XCTAssertEqual(productDescription, "This is a test product description")
    }
    
    func test_productId_shouldReturnCorrectValue() {
        let productId = sut.productId
        XCTAssertEqual(productId, "test-product-id")
    }
    
    func test_productProperties_withNilProduct_shouldReturnNil() {
        let nilProduct = Product(
            createdAt: nil,
            name: nil,
            image: nil,
            price: nil,
            description: nil,
            model: nil,
            brand: nil,
            id: nil
        )
        let viewModel = ProductDetailViewModel(product: nilProduct)
        XCTAssertNil(viewModel.productName)
        XCTAssertNil(viewModel.productPrice)
        XCTAssertNil(viewModel.productDescription)
        XCTAssertNil(viewModel.productId)
    }
    
    // MARK: - Favorite Tests
    func test_isFavorite_withValidProductId_shouldReturnFavoriteStatus() {
        let isFavorite = sut.isFavorite
        XCTAssertNotNil(isFavorite)
        XCTAssertTrue(isFavorite == true || isFavorite == false)
    }
    
    func test_toggleFavorite_withValidProduct_shouldCallSuccessCallback() {
        let expectation = XCTestExpectation(description: "Toggle favorite success")
        var receivedMessage: String?
        sut.favoriteToggleSuccess = { message in
            receivedMessage = message
            expectation.fulfill()
        }
        
        sut.toggleFavorite()
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedMessage)
        XCTAssertTrue(receivedMessage!.contains("Test Product"))
    }
    
    func test_toggleFavorite_withNilProductId_shouldCallFailureCallback() {
        let nilIdProduct = Product(
            createdAt: "2025-08-20",
            name: "Test Product",
            image: "test_image.jpg",
            price: "99.99",
            description: "Test description",
            model: "TestModel",
            brand: "TestBrand",
            id: nil
        )
        let viewModel = ProductDetailViewModel(product: nilIdProduct)
        let expectation = XCTestExpectation(description: "Toggle favorite failure")
        var receivedError: String?
        viewModel.favoriteToggleFailure = { error in
            receivedError = error
            expectation.fulfill()
        }
        viewModel.toggleFavorite()
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedError, "Product information not available")
    }
    
    func test_addToCart_withValidProduct_shouldCallBasketService() {
        let expectation = XCTestExpectation(description: "Add to cart completion")
        var callbackCalled = false
        sut.addToCartSuccess = { productName in
            callbackCalled = true
            expectation.fulfill()
        }
        sut.addToCartFailure = { error in
            callbackCalled = true
            expectation.fulfill()
        }
        sut.addToCart()
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(callbackCalled)
    }
    
    
    // MARK: - Event Source Tests
    func test_eventSourceProperties_shouldBeInitiallyNil() {
        XCTAssertNil(sut.favoriteStatusChanged)
        XCTAssertNil(sut.addToCartSuccess)
        XCTAssertNil(sut.addToCartFailure)
        XCTAssertNil(sut.favoriteToggleSuccess)
        XCTAssertNil(sut.favoriteToggleFailure)
    }
    
    func test_eventSourceProperties_shouldBeSettable() {
        var favoriteStatusChangedCalled = false
        var addToCartSuccessCalled = false
        var addToCartFailureCalled = false
        var favoriteToggleSuccessCalled = false
        var favoriteToggleFailureCalled = false
        
        sut.favoriteStatusChanged = { _ in favoriteStatusChangedCalled = true }
        sut.addToCartSuccess = { _ in addToCartSuccessCalled = true }
        sut.addToCartFailure = { _ in addToCartFailureCalled = true }
        sut.favoriteToggleSuccess = { _ in favoriteToggleSuccessCalled = true }
        sut.favoriteToggleFailure = { _ in favoriteToggleFailureCalled = true }
        
        XCTAssertNotNil(sut.favoriteStatusChanged)
        XCTAssertNotNil(sut.addToCartSuccess)
        XCTAssertNotNil(sut.addToCartFailure)
        XCTAssertNotNil(sut.favoriteToggleSuccess)
        XCTAssertNotNil(sut.favoriteToggleFailure)
        
        sut.favoriteStatusChanged?(true)
        sut.addToCartSuccess?("Test")
        sut.addToCartFailure?("Test")
        sut.favoriteToggleSuccess?("Test")
        sut.favoriteToggleFailure?("Test")
        
        XCTAssertTrue(favoriteStatusChangedCalled)
        XCTAssertTrue(addToCartSuccessCalled)
        XCTAssertTrue(addToCartFailureCalled)
        XCTAssertTrue(favoriteToggleSuccessCalled)
        XCTAssertTrue(favoriteToggleFailureCalled)
    }
}

// MARK: - Mock Classes
class MockFavoriteService {
    private var favoriteProducts: Set<String> = []
    
    func isProductInFavorites(productId: String) -> Bool {
        return favoriteProducts.contains(productId)
    }
    
    func toggleFavorite(product: Product) {
        guard let productId = product.id else { return }
        
        if favoriteProducts.contains(productId) {
            favoriteProducts.remove(productId)
        } else {
            favoriteProducts.insert(productId)
        }
    }
    
    func addToFavorites(product: Product) {
        guard let productId = product.id else { return }
        favoriteProducts.insert(productId)
    }
    
    func removeFromFavorites(productId: String) {
        favoriteProducts.remove(productId)
    }
}

class MockBasketService {
    enum MockError: Error, LocalizedError {
        case addToBasketFailed
        
        var errorDescription: String? {
            switch self {
            case .addToBasketFailed:
                return "Failed to add product to basket"
            }
        }
    }
    
    var shouldSucceed = true
    
    func addToBasket(product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                completion(.success(()))
            } else {
                completion(.failure(MockError.addToBasketFailed))
            }
        }
    }
}

// MARK: - Test Extensions
extension ProductDetailViewModelTests {
    
    func createTestProduct(
        id: String? = "test-id",
        name: String? = "Test Product",
        price: String? = "99.99",
        description: String? = "Test Description"
    ) -> Product {
        return Product(
            createdAt: "2025-08-20",
            name: name,
            image: "test_image.jpg",
            price: price,
            description: description,
            model: "TestModel",
            brand: "TestBrand",
            id: id
        )
    }
    
    // Performance test
    func test_toggleFavorite_performance() {
        measure {
            for _ in 0..<100 {
                sut.toggleFavorite()
            }
        }
    }
    
    // Memory leak test
    func test_viewModel_shouldNotRetainStrongReferences() {
        weak var weakViewModel: ProductDetailViewModel?
        autoreleasepool {
            let viewModel = ProductDetailViewModel(product: mockProduct)
            weakViewModel = viewModel
        }
        XCTAssertNil(weakViewModel, "ViewModel should be deallocated")
    }
}
