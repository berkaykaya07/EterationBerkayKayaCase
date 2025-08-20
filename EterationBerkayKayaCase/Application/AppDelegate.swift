//
//  AppDelegate.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let bounds = UIScreen.main.bounds
        self.window = UIWindow(frame: bounds)
        window?.makeKeyAndVisible()
        app.router.window = window
        app.router.startApplication()
        
        return true
    }

}

