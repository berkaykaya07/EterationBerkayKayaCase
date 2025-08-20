//
//  BasketViewModelTest.swift
//  EterationBerkayKayaCaseTests
//
//  Created by Berkay on 20.08.2025.
//

import XCTest
import CoreData
@testable import EterationBerkayKayaCase

class BasketViewModelTests: XCTestCase {
    
    var viewModel: BasketViewModel!
    
    override func setUp() {
        super.setUp()
        setupInMemoryCoreData()
        viewModel = BasketViewModel()
    }
    
    override func tearDown() {
        clearBasketItems()
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Core Data Setup
    private func setupInMemoryCoreData() {
        clearBasketItems()
    }
    
    private func clearBasketItems() {
        let fetchRequest: NSFetchRequest<BasketItem> = BasketItem.fetchRequest()
        do {
            let items = try CoreDataManager.shared.context.fetch(fetchRequest)
            for item in items {
                CoreDataManager.shared.context.delete(item)
            }
            try CoreDataManager.shared.context.save()
        } catch {
            print("Error clearing basket items: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    private func createBasketItem(productId: String, name: String, price: String, quantity: Int32) {
        CoreDataManager.shared.addBasketItem(
            productId: productId,
            productName: name,
            price: price,
            quantity: quantity
        )
    }
    
    // MARK: - Initialization Tests
    func testViewModelInitialization() {
        let newViewModel = BasketViewModel()
        XCTAssertNotNil(newViewModel)
        XCTAssertEqual(newViewModel.numberOfItems, 0)
    }
    
    // MARK: - DataSource Tests
    func testNumberOfItemsWhenBasketIsEmpty() {
        viewModel.didLoad()
        XCTAssertEqual(viewModel.numberOfItems, 0)
    }
    
    // MARK: - Event Source Tests
    func testReloadDataCallbackTriggered() {
        let expectation = XCTestExpectation(description: "Reload data callback should be triggered")
        viewModel.reloadData = {
            expectation.fulfill()
        }
        viewModel.didLoad()
        wait(for: [expectation], timeout: 1.0)
    }

    
    func testShowEmptyStateWhenBasketIsEmpty() {
        let expectation = XCTestExpectation(description: "Show empty state should be called")
        viewModel.showEmptyState = {
            expectation.fulfill()
        }
        viewModel.didLoad()
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Complete Order Tests
    func testCompleteOrderWithEmptyBasket() {
        let expectation = XCTestExpectation(description: "Order completion should fail with empty basket")
        viewModel.didLoad()
        var receivedError: String?
        viewModel.orderCompletedFailure = { error in
            receivedError = error
            expectation.fulfill()
        }
        viewModel.completeOrder()
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedError, "Your basket is empty!")
    }
    
    // MARK: - Notification Tests
    func testBasketDidUpdateNotification() {
        let expectation = XCTestExpectation(description: "Basket update should trigger reload")
        viewModel.reloadData = {
            expectation.fulfill()
        }
        NotificationCenter.default.post(name: .basketDidUpdate, object: nil)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testBasketItemAddedNotification() {
        let expectation = XCTestExpectation(description: "Basket item added should trigger reload")
        viewModel.reloadData = {
            expectation.fulfill()
        }
        NotificationCenter.default.post(name: .basketItemAdded, object: nil)
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testBasketItemQuantityUpdatedNotification() {
        let reloadExpectation = XCTestExpectation(description: "Reload data should be called")
        let updateTotalExpectation = XCTestExpectation(description: "Update total should be called")
        
        createBasketItem(productId: "1", name: "iPhone", price: "100", quantity: 1)
        viewModel.didLoad()
        
        viewModel.reloadData = {
            reloadExpectation.fulfill()
        }
        
        viewModel.updateTotalAmount = { _ in
            updateTotalExpectation.fulfill()
        }
        
        NotificationCenter.default.post(
            name: .basketItemQuantityUpdated,
            object: nil,
            userInfo: [
                "productId": "1",
                "newQuantity": 5
            ]
        )
        
        wait(for: [reloadExpectation, updateTotalExpectation], timeout: 1.0)
    }
    
    func testShowEmptyStateWhenLastItemRemoved() {
        let showEmptyExpectation = XCTestExpectation(description: "Show empty state should be called")
        
        createBasketItem(productId: "1", name: "iPhone", price: "100", quantity: 1)
        viewModel.didLoad()
        viewModel.showEmptyState = {
            showEmptyExpectation.fulfill()
        }
        CoreDataManager.shared.deleteBasketItem(productId: "1")
        NotificationCenter.default.post(
            name: .basketItemRemoved,
            object: nil,
            userInfo: ["productId": "1"]
        )
        wait(for: [showEmptyExpectation], timeout: 1.0)
    }
    
    // MARK: - Integration Tests
    func testQuantityUpdateViaBasketService() {
        createBasketItem(productId: "1", name: "iPhone", price: "100", quantity: 1)
        viewModel.didLoad()
        
        let expectation = XCTestExpectation(description: "Quantity should be updated")
        viewModel.updateTotalAmount = { amount in
            if amount == "300₺" { // 100 * 3 = 300
                expectation.fulfill()
            }
        }
        BasketService.shared.updateQuantity(productId: "1", newQuantity: 3)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRealTimeNotificationHandling() {
        let expectation = XCTestExpectation(description: "Real notification should be handled")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.reloadData = {
            expectation.fulfill()
        }
        
        viewModel.didLoad()
        let product = createMockProduct(id: "test1", name: "Test Product", price: "50")
        BasketService.shared.addToBasket(product: product) { _ in
            
        }
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - Mock Product for Testing
func createMockProduct(id: String, name: String, price: String) -> Product {
    return Product(
        createdAt: nil,
        name: name,
        image: nil,
        price: price,
        description: nil,
        model: nil,
        brand: nil,
        id: id
    )
}
