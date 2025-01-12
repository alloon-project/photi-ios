//
//  EnterIdCoordinator.swift
//  LogInImpl
//
//  Created by jung on 6/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol EnterIdListener: AnyObject {
  func didTapBackButtonAtEnterId()
  func didFinishEnterId(userName: String)
}

protocol EnterIdPresentable { }

final class EnterIdCoordinator: ViewableCoordinator<EnterIdPresentable> {
  weak var listener: EnterIdListener?
  
  private let viewModel: EnterIdViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: EnterIdViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

extension EnterIdCoordinator: EnterIdCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtEnterId()
  }
  
  func didTapNextButton(userName: String) {
    listener?.didFinishEnterId(userName: userName)
  }
}
