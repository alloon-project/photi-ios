//
//  NoneMemberHomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 9/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol NoneMemberHomeListener: AnyObject {
  func didTapLogInButtonAtNoneMemberHome()
}

protocol NoneMemberHomePresentable: AnyObject { }

final class NoneMemberHomeCoordinator: ViewableCoordinator<NoneMemberHomePresentable> {
  weak var listener: NoneMemberHomeListener?

  private let viewModel: NoneMemberHomeViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: NoneMemberHomeViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - NoneMemberHomeCoordinatable
extension NoneMemberHomeCoordinator: NoneMemberHomeCoordinatable {
  func didTapLogInButton() {
    listener?.didTapLogInButtonAtNoneMemberHome()
  }
}
