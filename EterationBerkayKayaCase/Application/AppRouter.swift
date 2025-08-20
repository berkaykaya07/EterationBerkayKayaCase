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
                rootViewController: ViewController(),
                title: "",
                iconName: "iconHome"
            ),
            createNavigationController(
                rootViewController: UIViewController(),
                title: "",
                iconName: "iconBasket"
            ),
            createNavigationController(
                rootViewController: UIViewController(),
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

}
