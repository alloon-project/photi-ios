
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
    let appContainer = AppContainer(dependency: AppDependency())
    let appCoordinator = appContainer.coordinator()
    
    appCoordinator.start()
    
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = appCoordinator.viewControllerable.uiviewController
    window.makeKeyAndVisible()
    self.window = window
    self.appCoordinator = appCoordinator
    
    return true
  }
  
}
