//
//  AppDelegate.swift
//  Alloon-DEV
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  private var appCoordinator: Coordinating?
  var window: UIWindow?
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    let navigationController = UINavigationController()
    let appContainer = AppContainer(dependency: AppDependency())
    
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = navigationController
    window.makeKeyAndVisible()
    self.window = window
    
    self.appCoordinator = appContainer.coordinator()
    self.appCoordinator?.start(at: navigationController)
    
    return true
  }
  
}
