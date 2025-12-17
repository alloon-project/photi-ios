//
//  AppDelegate.swift
//  Photi-DEV
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Coordinator

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  private var appCoordinator: Coordinating?
  private let appContainer = AppContainer(dependency: AppDependency())
  var window: UIWindow?
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    UIViewController.swizzleLifecycle()
    UIViewController.swizzleLifecycleMethods()
    configureWindowForSplash()
    return true
  }
}

// MARK: - Private Methods
private extension AppDelegate {
  func configureWindowForSplash() {
    let window = UIWindow(frame: UIScreen.main.bounds)
    let viewModel = SplashViewModel(useCase: appContainer.appUseCase)
    let viewController = SplashViewController(viewModel: viewModel)
    
    window.rootViewController = viewController
    window.makeKeyAndVisible()
    viewModel.listener = self
    self.window = window
  }
  
  func launchMainApp() {
    guard let window else { return }
    let appCoordinator = appContainer.coordinator()
    
    appCoordinator.start()
    
    window.rootViewController = appCoordinator.viewControllerable.uiviewController
    self.appCoordinator = appCoordinator
  }
}

extension AppDelegate: SplashListener {
  func didFinishSplash() {
    launchMainApp()
  }
}
