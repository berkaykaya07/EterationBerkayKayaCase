//
//  FilterProductsViewModel.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation

protocol FilterProductsDataSource {
    var selectedSortType: SortType { get }
    var selectedBrands: Set<String> { get }
    var selectedModels: Set<String> { get }
    
    func setupFilterData(with products: [Product],
                         currentSort: SortType,
                         currentBrands: Set<String>,
                         currentModels: Set<String>)
    func applyFilters()
    func searchBrands(with text: String)
    func searchModels(with text: String)
}

protocol FilterProductsEventSource {
    var reloadData: VoidClosure? { get }

}

protocol FilterProductsProtocol: FilterProductsDataSource, FilterProductsEventSource {}

final class FilterProductsViewModel: BaseViewModel, FilterProductsProtocol {
    
    // MARK: - DataSource Properties
    private(set) var availableBrands: [String] = []
    private(set) var availableModels: [String] = []
    private(set) var filteredBrands: [String] = []
    private(set) var filteredModels: [String] = []
    
    var selectedSortType: SortType = .none
    var selectedBrands: Set<String> = []
    var selectedModels: Set<String> = []
    
    // MARK: - Private Properties
    private var allProducts: [Product] = []
    private var brandSearchText: String = ""
    private var modelSearchText: String = ""
    
    // MARK: - EventSource
    var onFiltersApplied: ((SortType, Set<String>, Set<String>) -> Void)?
    var reloadData: VoidClosure?
       
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    func setupFilterData(with products: [Product],
                         currentSort: SortType = .none,
                         currentBrands: Set<String> = [],
                         currentModels: Set<String> = []) {
        self.allProducts = products
        extractFilterOptions()
        resetSearchFilters()
        self.selectedSortType = currentSort
        self.selectedBrands = currentBrands
        self.selectedModels = currentModels
    }
    
    func applyFilters() {
        onFiltersApplied?(selectedSortType, selectedBrands, selectedModels)
    }
    
    func searchBrands(with text: String) {
        brandSearchText = text
        updateFilteredBrands()
        reloadData?()
    }
    
    func searchModels(with text: String) {
        modelSearchText = text
        updateFilteredModels()
        reloadData?()
    }
}

// MARK: - Private Methods
private extension FilterProductsViewModel {
    
    private func extractFilterOptions() {
        let brands = allProducts.compactMap { $0.brand }.filter { !$0.isEmpty }
        let models = allProducts.compactMap { $0.model }.filter { !$0.isEmpty }
        availableBrands = Array(Set(brands)).sorted()
        availableModels = Array(Set(models)).sorted()
    }
    
    private func resetSearchFilters() {
        brandSearchText = ""
        modelSearchText = ""
        updateFilteredBrands()
        updateFilteredModels()
        reloadData?()
    }
    
    private func updateFilteredBrands() {
        if brandSearchText.isEmpty {
            filteredBrands = availableBrands
        } else {
            filteredBrands = availableBrands.filter { brand in
                brand.lowercased().contains(brandSearchText.lowercased())
            }
        }
    }
    
    private func updateFilteredModels() {
        if modelSearchText.isEmpty {
            filteredModels = availableModels
        } else {
            filteredModels = availableModels.filter { model in
                model.lowercased().contains(modelSearchText.lowercased())
            }
        }
    }
}

enum SortType {
    case none
    case oldToNew
    case newToOld
    case priceHighToLow
    case priceLowToHigh
}
