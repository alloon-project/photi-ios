//
//  FindIdCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator
import LogIn

protocol FindIdListener: AnyObject {
  func didTapBackButtonAtFindId()
  func didFinishAtFindId()
}

protocol FindIdPresentable { }

final class FindIdCoordinator: ViewableCoordinator<FindIdPresentable>, FindIdCoordinatable {
  weak var listener: FindIdListener?
  
  private let viewModel: any FindIdViewModelType
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: FindIdViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  func isRequestSucceed() {
    listener?.didFinishAtFindId()
  }
  func didTapBackButton() {
    listener?.didTapBackButtonAtFindId()
  }
}
