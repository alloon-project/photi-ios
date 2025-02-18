//
//  ResignAuthCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 2/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import LogIn

protocol ResignAuthListener: AnyObject {
  func didTapBackButtonAtResignPassword()
  func didFinishAtResignPassword()
}

protocol ResignAuthPresentable { }

final class ResignAuthCoordinator: ViewableCoordinator<ResignAuthPresentable>, ResignAuthCoordinatable {
  weak var listener: ResignAuthListener?
  
  private let viewModel: any ResignAuthViewModelType
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ResignAuthViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  func isRequestSucceed() {
    listener?.didFinishAtResignPassword()
  }
  func didTapBackButton() {
    listener?.didTapBackButtonAtResignPassword()
  }
}
