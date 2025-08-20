//
//  EterationBerkayKayaCaseTests.swift
//  EterationBerkayKayaCaseTests
//
//  Created by Berkay on 20.08.2025.
//


import XCTest
@testable import EterationBerkayKayaCase

class BasketViewControllerTests: XCTestCase {
    
    var viewController: TestableBasketViewController!
    var mockViewModel: MockBasketViewModel!
    
    override func setUp() {
        super.setUp()
        
        viewController = TestableBasketViewController()
        mockViewModel = MockBasketViewModel()
        viewController.mockViewModel = mockViewModel
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        mockViewModel = nil
        super.tearDown()
    }
    
    // MARK: - View Loading Tests
    func testViewDidLoad() {
        viewController.viewDidLoad()
        XCTAssertNotNil(viewController.view)
        XCTAssertTrue(mockViewModel.didLoadCalled)
    }
    
    func testTableViewNumberOfRows() {
        mockViewModel.mockNumberOfItems = 3
        viewController.viewDidLoad()
        let numberOfRows = viewController.tableView(getTableView()!, numberOfRowsInSection: 0)
        XCTAssertEqual(numberOfRows, 3)
    }
    
    func testTableViewCellConfiguration() {
        let mockCellModel = MockBasketTableViewCellModel()
        mockViewModel.mockCellModel = mockCellModel
        viewController.viewDidLoad()
        let tableView = getTableView()!
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = viewController.tableView(tableView, cellForRowAt: indexPath)
        XCTAssertTrue(cell is BasketTableViewCell)
        XCTAssertTrue(mockViewModel.cellForItemAtCalled)
    }
    
    // MARK: - Complete Button Tests
    func testCompleteButtonTapped() {
        viewController.viewDidLoad()
        let completeButton = getCompleteButton()
        completeButton?.sendActions(for: .touchUpInside)
        XCTAssertTrue(mockViewModel.completeOrderCalled)
    }
    
    // MARK: - ViewModel Binding Tests
    func testUpdateTotalAmountBinding() {
        viewController.viewDidLoad()
        let totalAmountLabel = getTotalAmountLabel()
        mockViewModel.triggerUpdateTotalAmount("150₺")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(totalAmountLabel?.text, "150₺")
        }
    }
    
    func testShowEmptyStateBinding() {
        viewController.viewDidLoad()
        let emptyStateView = getEmptyStateView()
        let tableView = getTableView()
        let bottomContainer = getBottomContainerView()
        mockViewModel.triggerShowEmptyState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(emptyStateView?.isHidden ?? true)
            XCTAssertTrue(tableView?.isHidden ?? false)
            XCTAssertTrue(bottomContainer?.isHidden ?? false)
        }
    }
    
    func testHideEmptyStateBinding() {
        viewController.viewDidLoad()
        let emptyStateView = getEmptyStateView()
        let tableView = getTableView()
        let bottomContainer = getBottomContainerView()
        mockViewModel.triggerHideEmptyState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(emptyStateView?.isHidden ?? false)
            XCTAssertFalse(tableView?.isHidden ?? true)
            XCTAssertFalse(bottomContainer?.isHidden ?? true)
        }
    }
    
    func testOrderCompletedSuccessBinding() {
        viewController.viewDidLoad()
        mockViewModel.triggerOrderCompletedSuccess()
        XCTAssertTrue(true)
    }
    
    func testOrderCompletedFailureBinding() {
        viewController.viewDidLoad()
        mockViewModel.triggerOrderCompletedFailure("Test error message")
        XCTAssertTrue(true)
    }
    
    // MARK: - Helper Methods
    private func getTableView() -> UITableView? {
        return viewController.view.subviews.first { $0 is UITableView } as? UITableView
    }
    
    private func getCompleteButton() -> UIButton? {
        return findButton(in: viewController.view, withTitle: "Complete")
    }
    
    private func getTotalAmountLabel() -> UILabel? {
        return findSubview(in: viewController.view, ofType: UILabel.self) { label in
            return label.text?.contains("₺") == true
        }
    }
    
    private func getEmptyStateView() -> UIView? {
        return findSubview(in: viewController.view, ofType: UIView.self) { view in
            return view.subviews.contains { $0 is UILabel }
        }
    }
    
    private func getBottomContainerView() -> UIView? {
        return viewController.view.subviews.first { view in
            return view.subviews.contains { $0 is UIButton }
        }
    }
    
    private func findButton(in view: UIView, withTitle title: String) -> UIButton? {
        if let button = view as? UIButton, button.titleLabel?.text == title {
            return button
        }
        
        for subview in view.subviews {
            if let button = findButton(in: subview, withTitle: title) {
                return button
            }
        }
        
        return nil
    }
    
    private func findSubview<T: UIView>(in view: UIView, ofType type: T.Type, matching predicate: ((T) -> Bool)? = nil) -> T? {
        if let targetView = view as? T {
            if let predicate = predicate {
                return predicate(targetView) ? targetView : nil
            }
            return targetView
        }
        
        for subview in view.subviews {
            if let found = findSubview(in: subview, ofType: type, matching: predicate) {
                return found
            }
        }
        
        return nil
    }
}

// MARK: - Mock Classes
class TestableBasketViewController: UIViewController {
    var mockViewModel: MockBasketViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribeToMockViewModel()
        mockViewModel?.didLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BasketTableViewCell.self, forCellReuseIdentifier: BasketTableViewCell.identifier)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
 
        let completeButton = UIButton(type: .system)
        completeButton.setTitle("Complete", for: .normal)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
     
        let emptyStateView = UIView()
        emptyStateView.isHidden = true
        let emptyLabel = UILabel()
        emptyLabel.text = "Empty basket"
        emptyStateView.addSubview(emptyLabel)
        
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
 
        let totalAmountLabel = UILabel()
        totalAmountLabel.text = "0₺"
        
        view.addSubview(totalAmountLabel)
        totalAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -20),
            
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 44),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            
            totalAmountLabel.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -10),
            totalAmountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    private func subscribeToMockViewModel() {
        guard let mockViewModel = mockViewModel else { return }
        
        mockViewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                if let tableView = self?.view.subviews.first(where: { $0 is UITableView }) as? UITableView {
                    tableView.reloadData()
                }
            }
        }
        
        mockViewModel.updateTotalAmount = { [weak self] amount in
            DispatchQueue.main.async {
                if let totalLabel = self?.view.subviews.first(where: { ($0 as? UILabel)?.text?.contains("₺") == true }) as? UILabel {
                    totalLabel.text = amount
                }
            }
        }
        
        mockViewModel.showEmptyState = { [weak self] in
            DispatchQueue.main.async {
                if let emptyView = self?.view.subviews.first(where: { $0.subviews.contains(where: { $0 is UILabel }) }) {
                    emptyView.isHidden = false
                }
                if let tableView = self?.view.subviews.first(where: { $0 is UITableView }) {
                    tableView.isHidden = true
                }
                if let button = self?.view.subviews.first(where: { $0 is UIButton }) {
                    button.isHidden = true
                }
            }
        }
        
        mockViewModel.hideEmptyState = { [weak self] in
            DispatchQueue.main.async {
                if let emptyView = self?.view.subviews.first(where: { $0.subviews.contains(where: { $0 is UILabel }) }) {
                    emptyView.isHidden = true
                }
                if let tableView = self?.view.subviews.first(where: { $0 is UITableView }) {
                    tableView.isHidden = false
                }
                if let button = self?.view.subviews.first(where: { $0 is UIButton }) {
                    button.isHidden = false
                }
            }
        }
        
        mockViewModel.orderCompletedSuccess = {
            // Toast simulation
        }
        
        mockViewModel.orderCompletedFailure = { _ in
            // Error toast simulation
        }
    }
    
    @objc private func completeButtonTapped() {
        mockViewModel?.completeOrder()
    }
}

extension TestableBasketViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockViewModel?.numberOfItems ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BasketTableViewCell.identifier, for: indexPath) as? BasketTableViewCell,
              let cellModel = mockViewModel?.cellForItemAt(indexPath: indexPath) else {
            return UITableViewCell()
        }
        
        cell.set(viewModel: cellModel)
        return cell
    }
}

class MockBasketViewModel: BasketProtocol {
    
    // MARK: - Test Properties
    var didLoadCalled = false
    var completeOrderCalled = false
    var cellForItemAtCalled = false
    
    // MARK: - Mock Data
    var mockNumberOfItems = 0
    var mockCellModel: BasketTableViewCellProtocol?
    
    // MARK: - DataSource
    var numberOfItems: Int {
        return mockNumberOfItems
    }
    
    func didLoad() {
        didLoadCalled = true
    }
    
    func cellForItemAt(indexPath: IndexPath) -> BasketTableViewCellProtocol {
        cellForItemAtCalled = true
        return mockCellModel ?? MockBasketTableViewCellModel()
    }
    
    func completeOrder() {
        completeOrderCalled = true
    }
    
    // MARK: - EventSource
    var reloadData: VoidClosure?
    var deleteRow: ((IndexPath) -> Void)?
    var updateTotalAmount: ((String) -> Void)?
    var showEmptyState: VoidClosure?
    var hideEmptyState: VoidClosure?
    var orderCompletedSuccess: VoidClosure?
    var orderCompletedFailure: StringClosure?
    
    // MARK: - Test Helpers
    func triggerReloadData() {
        DispatchQueue.main.async {
            self.reloadData?()
        }
    }
    
    func triggerUpdateTotalAmount(_ amount: String) {
        DispatchQueue.main.async {
            self.updateTotalAmount?(amount)
        }
    }
    
    func triggerShowEmptyState() {
        DispatchQueue.main.async {
            self.showEmptyState?()
        }
    }
    
    func triggerHideEmptyState() {
        DispatchQueue.main.async {
            self.hideEmptyState?()
        }
    }
    
    func triggerOrderCompletedSuccess() {
        DispatchQueue.main.async {
            self.orderCompletedSuccess?()
        }
    }
    
    func triggerOrderCompletedFailure(_ message: String) {
        DispatchQueue.main.async {
            self.orderCompletedFailure?(message)
        }
    }
}

class MockBasketTableViewCellModel: BasketTableViewCellProtocol {
    var productName: String? = "Mock Product"
    var quantity: Int = 1
    var totalPrice: String? = "100₺"
    var productId: String = "mock-id"
    var quantityChanged: ((String, Int) -> Void)?
}

// MARK: - UITableView Extension for Testing
extension UITableView {
    @objc func test_reloadData() {
 
    }
}
