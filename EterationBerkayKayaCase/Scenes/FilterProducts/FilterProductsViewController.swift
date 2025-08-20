//
//  FilterProductsViewController.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

final class FilterProductsViewController: BaseViewController<FilterProductsViewModel> {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let headerSeparatorLine = UIView()
    private let sortByLabel = UILabel()
    private let sortByStackView = UIStackView()
    private let brandLabel = UILabel()
    private let brandSearchBar = UISearchBar()
    private let brandTableView = UITableView()
    private let modelLabel = UILabel()
    private let modelSearchBar = UISearchBar()
    private let modelTableView = UITableView()
    private let primaryButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureComponents()
        subscribeViewModel()
        updateSortSelectionOnLoad()
    }
}

// MARK: - UILayout
private extension FilterProductsViewController {
    
   private func setupUI() {
        addScrollView()
        addSubviews()
        setupConstraints()
    }
    
    private func addScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [scrollView, contentView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
   private func addSubviews() {
        view.addSubview(primaryButton)
        
        [closeButton, titleLabel, headerSeparatorLine, sortByLabel, sortByStackView,
         createSeparatorLine(), brandLabel, brandSearchBar, brandTableView,
         createSeparatorLine(), modelLabel, modelSearchBar, modelTableView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        setupSortOptions()
        setupKeyboardDismissAll()
    }
    
   private func setupKeyboardDismissAll() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupSortOptions() {
        let sortOptions = [
            ("Old to new", SortType.oldToNew),
            ("New to old", SortType.newToOld),
            ("Price high to low", SortType.priceHighToLow),
            ("Price low to High", SortType.priceLowToHigh)
        ]
        
        for (index, (title, sortType)) in sortOptions.enumerated() {
            let stack = createSortOptionStack(title: title, isSelected: false, sortType: sortType, tag: index)
            sortByStackView.addArrangedSubview(stack)
        }
    }
    
    private func updateSortSelectionOnLoad() {
          let sortTypes: [SortType] = [.oldToNew, .newToOld, .priceHighToLow, .priceLowToHigh]
          
          if let selectedIndex = sortTypes.firstIndex(of: viewModel.selectedSortType) {
              updateSortOptionSelection(selectedIndex: selectedIndex)
          }
      }
    
    func setupConstraints() {
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        
        let separators = contentView.subviews.compactMap { $0 as UIView }.filter { view in
            view.backgroundColor == UIColor(red: 0, green: 0, blue: 0, alpha: 0.5) ||
            (view.backgroundColor == .white && view.layer.shadowOpacity > 0)
        }
        
        NSLayoutConstraint.activate([
            primaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            primaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            primaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            primaryButton.heightAnchor.constraint(equalToConstant: 38),
            
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26),
            closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            headerSeparatorLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            headerSeparatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerSeparatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerSeparatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            sortByLabel.topAnchor.constraint(equalTo: headerSeparatorLine.bottomAnchor, constant: 16),
            sortByLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            
            sortByStackView.topAnchor.constraint(equalTo: sortByLabel.bottomAnchor, constant: 22),
            sortByStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 31),
            sortByStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            separators[0].topAnchor.constraint(equalTo: sortByStackView.bottomAnchor, constant: 33),
            separators[0].leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            separators[0].trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            separators[0].heightAnchor.constraint(equalToConstant: 1),
            
            brandLabel.topAnchor.constraint(equalTo: separators[0].bottomAnchor, constant: 16),
            brandLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            
            brandSearchBar.topAnchor.constraint(equalTo: brandLabel.bottomAnchor, constant: 24),
            brandSearchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            brandSearchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            brandSearchBar.heightAnchor.constraint(equalToConstant: 40),
            
            brandTableView.topAnchor.constraint(equalTo: brandSearchBar.bottomAnchor, constant: 15),
            brandTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            brandTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            brandTableView.heightAnchor.constraint(equalToConstant: 90),
            
            separators[1].topAnchor.constraint(equalTo: brandTableView.bottomAnchor, constant: 33),
            separators[1].leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            separators[1].trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            separators[1].heightAnchor.constraint(equalToConstant: 1),
            
            modelLabel.topAnchor.constraint(equalTo: separators[1].bottomAnchor, constant: 16),
            modelLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            
            modelSearchBar.topAnchor.constraint(equalTo: modelLabel.bottomAnchor, constant: 24),
            modelSearchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            modelSearchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            modelSearchBar.heightAnchor.constraint(equalToConstant: 40),
            
            modelTableView.topAnchor.constraint(equalTo: modelSearchBar.bottomAnchor, constant: 15),
            modelTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            modelTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            modelTableView.heightAnchor.constraint(equalToConstant: 90),
            modelTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - Factory Methods
private extension FilterProductsViewController {
    
    private func createSeparatorLine() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return line
    }
    
    private func createSortOptionStack(title: String, isSelected: Bool, sortType: SortType, tag: Int) -> UIStackView {
        let stack = UIStackView()
        let button = UIButton(type: .system)
        let label = UILabel()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.appBlue.cgColor
        button.tintColor = .appBlue
        button.setImage(UIImage(named: isSelected ? "filledRadioButton" : "emptyRadioButton"), for: .normal)
        button.tag = tag
        
        button.addTarget(self, action: #selector(sortOptionTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 16),
            button.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        label.text = title
        label.font = .montserratRegular(size: 14)
        label.textColor = .black
        label.tag = tag
        
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 9
        stack.tag = tag
        
        stack.addArrangedSubview(button)
        stack.addArrangedSubview(label)
        return stack
    }
}

// MARK: - Configure Components
private extension FilterProductsViewController {
    
    private func configureComponents() {
        configureCloseButton()
        configureTitleLabel()
        configureHeaderSeparator()
        configureSortByLabel()
        configureSortByStackView()
        configureBrandLabel()
        configureSearchBars()
        configureTableViews()
        configurePrimaryButton()
    }
    
    private func configureCloseButton() {
        closeButton.setImage(UIImage(named: "iconClose"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.tintColor = .black
    }
    
    private func configureTitleLabel() {
        titleLabel.text = "Filter"
        titleLabel.font = .montserratLight(size: 20)
        titleLabel.textColor = .black
    }
    
    private func configureHeaderSeparator() {
        headerSeparatorLine.backgroundColor = .white
        headerSeparatorLine.layer.shadowColor = UIColor.black.cgColor
        headerSeparatorLine.layer.shadowOpacity = 0.3
        headerSeparatorLine.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    private func configureSortByLabel() {
        sortByLabel.text = "Sort By"
        sortByLabel.font = .montserratRegular(size: 12)
        sortByLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.7)
    }
    
    private func configureSortByStackView() {
        sortByStackView.axis = .vertical
        sortByStackView.distribution = .fill
        sortByStackView.alignment = .fill
        sortByStackView.spacing = 15
    }
    
    private func configureBrandLabel() {
        brandLabel.text = "Brand"
        brandLabel.font = .montserratRegular(size: 12)
        brandLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.7)
        
        modelLabel.text = "Model"
        modelLabel.font = .montserratRegular(size: 12)
        modelLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.7)
    }
    
    private func configureSearchBars() {
        [brandSearchBar, modelSearchBar].forEach { searchBar in
            searchBar.placeholder = "Search"
            searchBar.searchBarStyle = .minimal
            searchBar.backgroundColor = .clear
            searchBar.barTintColor = .clear
            searchBar.searchTextField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
            searchBar.searchTextField.layer.cornerRadius = 8
            searchBar.searchTextField.font = .montserratRegular(size: 16)
            searchBar.searchTextField.textColor = .lightGray
            searchBar.delegate = self
            
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                textField.leftView?.tintColor = .systemGray
            }
        }
    }
    
    private func configureTableViews() {
        [brandTableView, modelTableView].forEach { tableView in
            tableView.register(FilterProductsTableViewCell.self, forCellReuseIdentifier: "FilterProductsTableViewCell")
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
        }
    }
    
    private func configurePrimaryButton() {
        primaryButton.setTitle("Primary", for: .normal)
        primaryButton.titleLabel?.font = .montserratBold(size: 18)
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.backgroundColor = .appBlue
        primaryButton.layer.cornerRadius = 4
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Actions
private extension FilterProductsViewController {
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func primaryButtonTapped() {
        viewModel.applyFilters()
    }
    
    @objc private func sortOptionTapped(_ sender: UIButton) {
        let sortTypes: [SortType] = [.oldToNew, .newToOld, .priceHighToLow, .priceLowToHigh]
        let tappedSortType = sortTypes[sender.tag]
        
        if viewModel.selectedSortType == tappedSortType {
            viewModel.selectedSortType = .none
            updateSortOptionSelection(selectedIndex: -1)
        } else {
            viewModel.selectedSortType = tappedSortType
            updateSortOptionSelection(selectedIndex: sender.tag)
        }
    }
    
    private func updateSortOptionSelection(selectedIndex: Int) {
        for (index, arrangedSubview) in sortByStackView.arrangedSubviews.enumerated() {
            guard let stack = arrangedSubview as? UIStackView,
                  let button = stack.arrangedSubviews.first as? UIButton else { continue }
            
            let isSelected = (selectedIndex != -1) && (index == selectedIndex)
            let imageName = isSelected ? "filledRadioButton" : "emptyRadioButton"
            button.setImage(UIImage(named: imageName), for: .normal)
        }
    }
    
    private func toggleBrandSelection(title: String, at indexPath: IndexPath) {
        if viewModel.selectedBrands.contains(title) {
            viewModel.selectedBrands.remove(title)
        } else {
            viewModel.selectedBrands.insert(title)
        }
        brandTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func toggleModelSelection(title: String, at indexPath: IndexPath) {
        if viewModel.selectedModels.contains(title) {
            viewModel.selectedModels.remove(title)
        } else {
            viewModel.selectedModels.insert(title)
        }
        modelTableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FilterProductsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case brandTableView: return viewModel.filteredBrands.count
        case modelTableView: return viewModel.filteredModels.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterProductsTableViewCell", for: indexPath) as! FilterProductsTableViewCell
        
        switch tableView {
        case brandTableView:
            let title = viewModel.filteredBrands[indexPath.row]
            let isSelected = viewModel.selectedBrands.contains(title)
            
            cell.set(viewModel: FilterProductsTableViewCellModel(title: title, isSelected: isSelected))
            cell.onToggleSelection = { [weak self] in
                self?.toggleBrandSelection(title: title, at: indexPath)
            }
            
        case modelTableView:
            let title = viewModel.filteredModels[indexPath.row]
            let isSelected = viewModel.selectedModels.contains(title)
            
            cell.set(viewModel: FilterProductsTableViewCellModel(title: title, isSelected: isSelected))
            cell.onToggleSelection = { [weak self] in
                self?.toggleModelSelection(title: title, at: indexPath)
            }
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}

// MARK: - ViewModel Subscription
private extension FilterProductsViewController {
    
    func subscribeViewModel() {
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.brandTableView.reloadData()
                self?.modelTableView.reloadData()
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension FilterProductsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch searchBar {
        case brandSearchBar:
            viewModel.searchBrands(with: searchText)
        case modelSearchBar:
            viewModel.searchModels(with: searchText)
        default:
            break
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        switch searchBar {
        case brandSearchBar:
            viewModel.searchBrands(with: "")
        case modelSearchBar:
            viewModel.searchModels(with: "")
        default:
            break
        }
        searchBar.resignFirstResponder()
    }
}
