//
//  ResignCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol ResignListener: AnyObject {
  func didTapBackButtonAtResign()
  func didTapCancelButtonAtResign()
  func didFisishedResign()
}

protocol ResignPresentable { }

final class ResignCoordinator: ViewableCoordinator<ResignPresentable> {
  weak var listener: ResignListener?

  private let viewModel: ResignViewModel
  
  private let resignAuthContainable: ResignAuthContainable
  private var resignAuthCoordinator: Coordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ResignViewModel,
    resignAuthContainable: ResignAuthContainable
  ) {
    self.viewModel = viewModel
    
    self.resignAuthContainable = resignAuthContainable
    
    super.init(viewControllerable)
    viewModel.coodinator = self
  }
}

// MARK: - Coordinatable
extension ResignCoordinator: ResignCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtResign()
  }
  
  func attachPasswordAuth() {
    guard resignAuthCoordinator == nil else { return }
    
    let coordinator = resignAuthContainable.coordinator(listener: self)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.resignAuthCoordinator = coordinator
  }
  
  func detachResignPassword() {
    guard let coordinator = resignAuthCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.resignAuthCoordinator = nil
  }
  
  func didTapCancelButton() {
    listener?.didTapCancelButtonAtResign()
  }
}

// MARK: - ResignAuthListener
extension ResignCoordinator: ResignAuthListener {
  func didTapBackButtonAtResignPassword() {
    detachResignPassword()
  }
  
  func didFinishAtResignPassword() {
    listener?.didFisishedResign()
  }
}
