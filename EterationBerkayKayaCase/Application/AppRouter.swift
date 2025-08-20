//
//  AppRouter.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

final class AppRouter {

    var window: UIWindow?
    
    private var tabBarController: UITabBarController?
    
    func startApplication() {
        guard let window else { fatalError("Window cannot be nil") }
        let mainTabBar = createMainTabBarController()
        self.tabBarController = mainTabBar
        window.rootViewController = mainTabBar
        setupBadges()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - TabBar Configuration
private extension AppRouter {
    
   private func createMainTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        configureTabBarAppearance(tabBarController.tabBar)
        tabBarController.viewControllers = createViewControllers()
        return tabBarController
    }
    
   private func configureTabBarAppearance(_ tabBar: UITabBar) {
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 4
        tabBar.layer.masksToBounds = false
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func createViewControllers() -> [UINavigationController] {
        return [
            createNavigationController(
                rootViewController: ProductsListingViewController(viewModel: ProductsListingViewModel()),
                title: "",
                iconName: "iconHome"
            ),
            createNavigationController(
                rootViewController: BasketViewController(viewModel: BasketViewModel()),
                title: "",
                iconName: "iconBasket"
            ),
            createNavigationController(
                rootViewController: FavoritesViewController(viewModel: FavoritesViewModel()),
                title: "Favorites",
                iconName: "iconFavourite"
            ),
            createNavigationController(
                rootViewController: UIViewController(),
                title: "Profile",
                iconName: "iconProfile"
            )
        ]
    }
    
    private func createNavigationController(
        rootViewController: UIViewController, title: String, iconName: String) -> UINavigationController {
        rootViewController.title = title
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        )
        return navigationController
    }
    
    private func setupBadges() {
        updateBasketBadge()
        updateFavoritesBadge()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(basketDidUpdate),
            name: .basketDidUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesDidUpdate),
            name: .favoriteItemAdded,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesDidUpdate),
            name: .favoriteItemRemoved,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesDidUpdate),
            name: .allFavoritesCleared,
            object: nil
        )
    }
}

// MARK: - Actions
private extension AppRouter {
    
    @objc private func basketDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.updateBasketBadge()
        }
    }
    
    @objc private func favoritesDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.updateFavoritesBadge()
        }
    }
    
    private func updateBasketBadge() {
        guard let tabBarController = tabBarController else { return }
        
        let totalItems = BasketService.shared.getTotalItemCount()
        let basketTabIndex = 1
        
        if totalItems > 0 {
            tabBarController.tabBar.items?[basketTabIndex].badgeValue = "\(totalItems)"
            tabBarController.tabBar.items?[basketTabIndex].badgeColor = .systemRed
        } else {
            tabBarController.tabBar.items?[basketTabIndex].badgeValue = nil
        }
    }
    
    private func updateFavoritesBadge() {
        guard let tabBarController = tabBarController else { return }
        
        let totalFavorites = FavoriteService.shared.getFavoriteCount()
        let favoritesTabIndex = 2
        
        if totalFavorites > 0 {
            tabBarController.tabBar.items?[favoritesTabIndex].badgeValue = "\(totalFavorites)"
            tabBarController.tabBar.items?[favoritesTabIndex].badgeColor = .systemYellow
        } else {
            tabBarController.tabBar.items?[favoritesTabIndex].badgeValue = nil
        }
    }
}
