//
//  AppDelegate.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Create a window the size of the screen
        window = UIWindow(frame: UIScreen.main.bounds)

        // Set root view controller to your GameViewController
        window?.rootViewController = GameViewController()
        window?.makeKeyAndVisible()

        return true
    }
}

