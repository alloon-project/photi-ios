//
//  LogInGuideCoordinator.swift
//  ChallengeImpl
//
//  Created by jung on 1/31/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol LogInGuideListener: AnyObject {
  func didTapBackButtonAtLogInGuide()
  func didTapLogInButtonAtLogInGuide()
}

protocol LogInGuidePresentable { }

final class LogInGuideCoordinator: ViewableCoordinator<LogInGuidePresentable> {
  weak var listener: LogInGuideListener?

  private let viewModel: LogInGuideViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: LogInGuideViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - LogInGuideCoordinatable
extension LogInGuideCoordinator: LogInGuideCoordinatable { }
