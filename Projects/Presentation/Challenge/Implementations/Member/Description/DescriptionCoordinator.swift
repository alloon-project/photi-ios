//
//  DescriptionCoordinator.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol DescriptionListener: AnyObject {
  func authenticatedFailedAtDescription()
  func networkUnstableAtDescription()
  func challengeNotFoundAtDescription()
}

protocol DescriptionPresentable { }

final class DescriptionCoordinator: ViewableCoordinator<DescriptionPresentable> {
  weak var listener: DescriptionListener?

  private let viewModel: DescriptionViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: DescriptionViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - DescriptionCoordinatable
extension DescriptionCoordinator: DescriptionCoordinatable {
  func authenticatedFailed() {
    listener?.authenticatedFailedAtDescription()
  }
  
  func networkUnstable() {
    listener?.networkUnstableAtDescription()
  }
  
  func challengeNotFound() {
    listener?.challengeNotFoundAtDescription()
  }
}
