//
//  LogInCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import LogIn

protocol LogInPresentable { }

final class LogInCoordinator: ViewableCoordinator<LogInPresentable> {
  weak var listener: LogInListener?
  private let viewModel: LogInViewModel
  private var signUpNavigationControllerable: NavigationControllerable?
  
  private let signUpContainable: SignUpContainable
  private var signUpCoordinator: Coordinating?
  
  private let findIdContainable: FindIdContainable
  private var findIdCoordinator: ViewableCoordinating?
  
  private let findPasswordContainable: FindPasswordContainable
  private var findPasswordCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: LogInViewModel,
    signUpContainable: SignUpContainable,
    findIdContainable: FindIdContainable,
    findPasswordContainable: FindPasswordContainable
  ) {
    self.viewModel = viewModel
    self.signUpContainable = signUpContainable
    self.findIdContainable = findIdContainable
    self.findPasswordContainable = findPasswordContainable
    
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  // MARK: - SignUp
  func attachSignUp() {
    guard
      signUpCoordinator == nil,
      let navigationController = viewControllerable.uiviewController.navigationController
    else { return }

    let navigation = NavigationControllerable(navigationController: navigationController)
    let coordinater = signUpContainable.coordinator(navigationControllerable: navigation, listener: self)
    addChild(coordinater)
    self.signUpCoordinator = coordinater
  }
  
  func detachSignUp() {
    guard let coordinater = signUpCoordinator else { return }
    removeChild(coordinater)
//    self.signUpNavigationControllerable = nil
    self.signUpCoordinator = nil
  }
  
  // MARK: - FindId
  func attachFindId() { 
    guard findIdCoordinator == nil else { return }
    
    let coordinater = findIdContainable.coordinator(listener: self)
    addChild(coordinater)
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.findIdCoordinator = coordinater
  }
  
  func detachFindId() { 
    guard let coordinater = findIdCoordinator else { return }
    
    removeChild(coordinater)
    viewControllerable.popViewController(animated: true)
    self.findIdCoordinator = nil
  }
  
  // MARK: - FindPassword
  func attachFindPassword() {
    guard findPasswordCoordinator == nil else { return }
    
    let coordinater = findPasswordContainable.coordinator(listener: self)
    addChild(coordinater)
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)

    self.findPasswordCoordinator = coordinater
  }
  
  func detachFindPassword(willRemoveView: Bool) {
    guard let coordinater = findPasswordCoordinator else { return }
    
    removeChild(coordinater)
    if willRemoveView { viewControllerable.popViewController(animated: true) }
    self.findPasswordCoordinator = nil
  }
}

// MARK: - Coorinatable
extension LogInCoordinator: LogInCoordinatable {
  func didFinishLogIn(userName: String) {
    listener?.didFinishLogIn(userName: userName)
  }
  
  func didTapBackButton() {
    listener?.didTapBackButtonAtLogIn()
  }
}

// MARK: - SignUpListener
extension LogInCoordinator: SignUpListener {
  func didFinishSignUp(userName: String) {
    detachSignUp()
    listener?.didFinishLogIn(userName: userName)
  }
  
  func didTapBackButtonAtSignUp() {
    detachSignUp()
  }
}

// MARK: - FindpasswordListener
extension LogInCoordinator: FindPasswordListener {
  func didTapBackButtonAtFindPassword() {
    detachFindPassword(willRemoveView: true)
  }
  
  func didFinishUpdatePassword() {
    detachFindPassword(willRemoveView: false)
    guard
      let navigationController = viewControllerable.uiviewController.navigationController,
      let viewControllerables = navigationController.viewControllers as? [ViewControllerable],
      viewControllerables.count >= 2
    else { return }

    let remainingVCs = Array(viewControllerables.prefix(2))
    viewControllerable.setViewControllers(remainingVCs, animated: true)
  }
}

// MARK: - FindIdListener
extension LogInCoordinator: FindIdListener {
  func didTapBackButtonAtFindId() {
    detachFindId()
  }
  
  func didFinishAtFindId() {
    detachFindId()
  }
}
