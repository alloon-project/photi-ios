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
}

protocol ResignPresentable { }

final class ResignCoordinator: ViewableCoordinator<ResignPresentable> {
  weak var listener: ResignListener?

  private let viewModel: ResignViewModel
  
  init(
    viewControllerable: ViewControllable,
    viewModel: ResignViewModel
  ) {
    self.viewModel = viewModel
    
    super.init(viewControllerable)
    viewModel.coodinator = self
  }
}

// MARK: - Coordinatable
extension ResignCoordinator: ResignCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtResign()
  }
  
  func attachPasswordAuth() {}
  
  func didTapCancelButton() {
    listener?.didTapCancelButtonAtResign()
  }
}
