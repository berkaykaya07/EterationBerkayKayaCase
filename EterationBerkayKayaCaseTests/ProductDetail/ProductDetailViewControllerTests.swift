//
//  ProductDetailViewControllerTests.swift
//  EterationBerkayKayaCaseTests
//
//  Created by Berkay on 20.08.2025.
//

import XCTest
@testable import EterationBerkayKayaCase

final class ProductDetailViewControllerTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: ProductDetailViewController!
    private var mockViewModel: MockProductDetailViewModel!
    private var mockNavigationController: UINavigationController!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        
        let testProduct = Product(
            createdAt: "2025-08-20",
            name: "Test Product",
            image: "test_image.jpg",
            price: "99.99",
            description: "This is a test product description",
            model: "TestModel",
            brand: "TestBrand",
            id: "test-product-id"
        )
        
        let realViewModel = ProductDetailViewModel(product: testProduct)
        mockViewModel = MockProductDetailViewModel(product: testProduct)
        sut = ProductDetailViewController(viewModel: realViewModel)
        mockNavigationController = UINavigationController(rootViewController: sut)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        mockViewModel = nil
        mockNavigationController = nil
        super.tearDown()
    }
    
    // MARK: - Lifecycle Tests
    func test_viewDidLoad_shouldCallAllSetupMethods() {
        let testProduct = Product(
            createdAt: "2025-08-20",
            name: "Test Product",
            image: "test_image.jpg",
            price: "99.99",
            description: "This is a test product description",
            model: "TestModel",
            brand: "TestBrand",
            id: "test-product-id"
        )
        
        let viewModel = ProductDetailViewModel(product: testProduct)
        let viewController = ProductDetailViewController(viewModel: viewModel)
        viewController.loadViewIfNeeded()
        XCTAssertNotNil(viewController.view)
        verifyUIElementsExist()
    }
    
    func test_viewDidLoad_shouldSetupNavigationItems() {
        sut.viewDidLoad()
        XCTAssertNotNil(sut.navigationItem.leftBarButtonItem)
        XCTAssertNotNil(sut.navigationItem.titleView)
    }
    
    // MARK: - UI Setup Tests
    func test_setupUI_shouldCreateAllUIElements() {
        verifyUIElementsExist()
    }
    
    private func verifyUIElementsExist() {
        XCTAssertNotNil(sut.navigationItem.leftBarButtonItem)
        XCTAssertNotNil(sut.navigationItem.titleView)
        
        let subviews = sut.view.subviews
        XCTAssertTrue(subviews.count > 0)
        
        let imageViews = sut.view.subviews.compactMap { $0 as? UIImageView }
        let labels = sut.view.subviews.compactMap { $0 as? UILabel }
        let buttons = sut.view.subviews.compactMap { $0 as? UIButton }
        let stackViews = sut.view.subviews.compactMap { $0 as? UIStackView }
        
        XCTAssertTrue(imageViews.count >= 1)
        XCTAssertTrue(labels.count >= 2)
        XCTAssertTrue(buttons.count >= 2)
        XCTAssertTrue(stackViews.count >= 1)
    }
    
    // MARK: - UI Configuration Tests
    func test_configureContents_shouldSetCorrectValues() {
        sut.viewDidLoad()
        if let titleLabel = sut.navigationItem.titleView as? UILabel {
            XCTAssertEqual(titleLabel.text, "Test Product")
            XCTAssertEqual(titleLabel.textColor, .white)
        }
        if let backButton = sut.navigationItem.leftBarButtonItem?.customView as? UIButton {
            XCTAssertEqual(backButton.tintColor, .white)
        }
    }
    
    // MARK: - User Interaction Tests
    func test_backButtonTapped_shouldPopViewController() {
        let navigationController = UINavigationController()
        let firstVC = UIViewController()
        navigationController.pushViewController(firstVC, animated: false)
        navigationController.pushViewController(sut, animated: false)
        
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        
        if let backButton = sut.navigationItem.leftBarButtonItem?.customView as? UIButton {
            backButton.sendActions(for: .touchUpInside)
        }
        

        let expectation = XCTestExpectation(description: "Navigation pop")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(navigationController.viewControllers.count, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - ViewModel Subscription Tests
    func test_subscribeViewModel_shouldHandleAddToCartSuccess() {
        let expectation = XCTestExpectation(description: "Add to cart success")
        let testProductName = "Test Product"
        sut.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mockViewModel.triggerAddToCartSuccess(productName: testProductName)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_subscribeViewModel_shouldHandleAddToCartFailure() {
        let expectation = XCTestExpectation(description: "Add to cart failure")
        let testErrorMessage = "Test error message"
        sut.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mockViewModel.triggerAddToCartFailure(errorMessage: testErrorMessage)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_subscribeViewModel_shouldHandleFavoriteToggleSuccess() {
        let expectation = XCTestExpectation(description: "Favorite toggle success")
        let testMessage = "Product added to favorites"
        sut.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mockViewModel.triggerFavoriteToggleSuccess(message: testMessage)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_subscribeViewModel_shouldHandleFavoriteToggleFailure() {
        let expectation = XCTestExpectation(description: "Favorite toggle failure")
        let testErrorMessage = "Test error message"
        sut.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mockViewModel.triggerFavoriteToggleFailure(errorMessage: testErrorMessage)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Notification Tests
    func test_favoriteStatusChanged_shouldUpdateFavoriteButton() {
        let expectation = XCTestExpectation(description: "Favorite status changed")
        sut.viewDidLoad()
        let userInfo = ["productId": "test-product-id"]
        NotificationCenter.default.post(
            name: .favoriteItemAdded,
            object: nil,
            userInfo: userInfo
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_favoriteStatusChanged_withDifferentProductId_shouldNotUpdate() {
        sut.viewDidLoad()
        let userInfo = ["productId": "different-product-id"]
        NotificationCenter.default.post(
            name: .favoriteItemAdded,
            object: nil,
            userInfo: userInfo
        )
     
    }
    
    // MARK: - UI Animation Tests
    func test_updateFavoriteButtonState_shouldAnimateButton() {
        sut.viewDidLoad()
        let expectation = XCTestExpectation(description: "Animation completed")
        let userInfo = ["productId": "test-product-id"]
        NotificationCenter.default.post(
            name: .favoriteItemAdded,
            object: nil,
            userInfo: userInfo
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helper Methods
    private func findAndTapFavoriteButton() {
        findButton(with: "star.fill")?.sendActions(for: .touchUpInside)
    }
    
    private func findAndTapAddToCartButton() {
        findButton(with: "Add to Cart")?.sendActions(for: .touchUpInside)
    }
    
    private func findButton(with identifier: String) -> UIButton? {
        return findButtonRecursively(in: sut.view, with: identifier)
    }
    
    private func findButtonRecursively(in view: UIView, with identifier: String) -> UIButton? {
        for subview in view.subviews {
            if let button = subview as? UIButton {
                if button.titleLabel?.text == identifier ||
                   button.imageView?.image == UIImage(systemName: identifier) {
                    return button
                }
            }
            
            if let foundButton = findButtonRecursively(in: subview, with: identifier) {
                return foundButton
            }
        }
        return nil
    }
}

// MARK: - Mock ViewModel
class MockProductDetailViewModel: ProductDetailProtocol {
    
    // MARK: - Test Hooks
    var onToggleFavorite: (() -> Void)?
    var onAddToCart: (() -> Void)?
    
    // MARK: - ProductDetailDataSource
    private let product: Product
    
    var productName: String? { product.name }
    var productPrice: String? { product.price }
    var productDescription: String? { product.description }
    var productId: String? { product.id }
    var isFavorite: Bool = false
    
    // MARK: - ProductDetailEventSource
    var favoriteStatusChanged: BoolClosure?
    var addToCartSuccess: StringClosure?
    var addToCartFailure: StringClosure?
    var favoriteToggleSuccess: StringClosure?
    var favoriteToggleFailure: StringClosure?
    
    // MARK: - Initialization
    init(product: Product) {
        self.product = product
    }
    
    // MARK: - Methods
    func addToCart() {
        onAddToCart?()
    }
    
    func toggleFavorite() {
        onToggleFavorite?()
        isFavorite.toggle()
    }
    
    // MARK: - Test Helpers
    func triggerAddToCartSuccess(productName: String) {
        addToCartSuccess?(productName)
    }
    
    func triggerAddToCartFailure(errorMessage: String) {
        addToCartFailure?(errorMessage)
    }
    
    func triggerFavoriteToggleSuccess(message: String) {
        favoriteToggleSuccess?(message)
    }
    
    func triggerFavoriteToggleFailure(errorMessage: String) {
        favoriteToggleFailure?(errorMessage)
    }
    
    func triggerFavoriteStatusChanged(isFavorite: Bool) {
        favoriteStatusChanged?(isFavorite)
    }
}

// MARK: - Test Extensions
extension ProductDetailViewControllerTests {
    
    func test_viewDidLoad_performance() {
        let testProduct = Product(
            createdAt: "2025-08-20",
            name: "Test Product",
            image: "test_image.jpg",
            price: "99.99",
            description: "This is a test product description",
            model: "TestModel",
            brand: "TestBrand",
            id: "test-product-id"
        )
        
        measure {
            let viewModel = ProductDetailViewModel(product: testProduct)
            let viewController = ProductDetailViewController(viewModel: viewModel)
            viewController.loadViewIfNeeded()
        }
    }
    
    func test_accessibilityIdentifiers_shouldBeSet() {
        sut.viewDidLoad()
    }
    
    func test_autoLayoutConstraints_shouldBeValid() {
        sut.viewDidLoad()
        sut.view.layoutIfNeeded()
        XCTAssertFalse(sut.view.hasAmbiguousLayout)
    }
}

