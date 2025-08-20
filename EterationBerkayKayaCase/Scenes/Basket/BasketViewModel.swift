//
//  BasketViewModel.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation

protocol BasketDataSource {
    var numberOfItems: Int { get }
    
    func didLoad()
    func cellForItemAt(indexPath: IndexPath) -> BasketTableViewCellProtocol
    func completeOrder()
}

protocol BasketEventSource {
    var reloadData: VoidClosure? { get }
    var deleteRow: ((IndexPath) -> Void)? { get }
    var updateTotalAmount: ((String) -> Void)? { get }
    var showEmptyState: VoidClosure? { get }
    var hideEmptyState: VoidClosure? { get }
    var orderCompletedSuccess: VoidClosure? { get }
    var orderCompletedFailure: StringClosure? { get }
}

protocol BasketProtocol: BasketDataSource, BasketEventSource {}


class BasketViewModel: BaseViewModel, BasketProtocol {
    
    // MARK: - EventSource Properties
    var reloadData: VoidClosure?
    var deleteRow: ((IndexPath) -> Void)?
    var updateTotalAmount: ((String) -> Void)?
    var showEmptyState: VoidClosure?
    var hideEmptyState: VoidClosure?
    var orderCompletedSuccess: VoidClosure?
    var orderCompletedFailure: StringClosure?

    // MARK: - DataSource Properties
    var numberOfItems: Int {
        return cellModels.count
    }
    
    func cellForItemAt(indexPath: IndexPath) -> BasketTableViewCellProtocol {
        guard indexPath.row < cellModels.count else {
            fatalError("Index out of bounds")
        }
        return cellModels[indexPath.row]
    }
    
    // MARK: - Private Properties
    private var totalAmount: String {
        return basketService.getFormattedTotalAmount()
    }
    private var isBasketEmpty: Bool {
        return cellModels.isEmpty
    }
    private var cellModels: [BasketTableViewCellModel] = []
    private let basketService = BasketService.shared
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupNotificationObservers()
        loadBasketItems()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    func didLoad() {
        loadBasketItems()
        updateUI()
    }

    func completeOrder() {
        guard !isBasketEmpty else {
            orderCompletedFailure?("Your basket is empty!")
            return
        }
        
        basketService.clearBasket { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.orderCompletedSuccess?()
            case .failure(let error):
                self.orderCompletedFailure?(error.localizedDescription)
            }
        }
    }

    
    // MARK: - Private Methods
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(basketDidUpdate),
            name: .basketDidUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(basketItemAdded),
            name: .basketItemAdded,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(basketItemRemoved),
            name: .basketItemRemoved,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(basketItemQuantityUpdated),
            name: .basketItemQuantityUpdated,
            object: nil
        )
    }
    
    private func loadBasketItems() {
        let basketItems = basketService.getBasketItems()
        
        cellModels = basketItems.compactMap { basketItem in
            guard let productId = basketItem.productId,
                  let productName = basketItem.productName,
                  let price = basketItem.price else {
                return nil
            }
            
            let cellModel = BasketTableViewCellModel(
                productId: productId,
                productName: productName,
                price: price,
                quantity: Int(basketItem.quantity)
            )
            
            cellModel.quantityChanged = { [weak self] productId, newQuantity in
                self?.basketService.updateQuantity(productId: productId, newQuantity: newQuantity)
            }
            return cellModel
        }
    }
    
    private func updateUI() {
        if self.isBasketEmpty {
            self.showEmptyState?()
        } else {
            self.hideEmptyState?()
        }
        self.reloadData?()
        self.updateTotalAmount?(self.totalAmount)
    }
    
    private func findCellModelIndex(by productId: String) -> Int? {
        return cellModels.firstIndex { $0.productId == productId }
    }
}

// MARK: - Notification Handlers
private extension BasketViewModel {
    
    @objc private func basketDidUpdate(_ notification: Notification) {
        loadBasketItems()
        updateUI()
    }
    
    @objc private func basketItemAdded(_ notification: Notification) {
        loadBasketItems()
        updateUI()
    }
    
    @objc private func basketItemRemoved(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let productId = userInfo["productId"] as? String,
              let index = findCellModelIndex(by: productId) else {
            loadBasketItems()
            updateUI()
            return
        }
        cellModels.remove(at: index)
        self.deleteRow?(IndexPath(row: index, section: 0))
        self.updateTotalAmount?(self.totalAmount)
        
        if self.isBasketEmpty {
            self.showEmptyState?()
        }
    }
    
    @objc private func basketItemQuantityUpdated(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let productId = userInfo["productId"] as? String,
              let newQuantity = userInfo["newQuantity"] as? Int,
              let index = findCellModelIndex(by: productId) else {
            loadBasketItems()
            updateUI()
            return
        }
        cellModels[index].updateQuantity(newQuantity)
        self.updateTotalAmount?(self.totalAmount)
        self.reloadData?()
    }
}
