//
//  ResignCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol ResignViewModelable: AnyObject { }

public protocol ResignListener: AnyObject {
  func didTapBackButtonAtResign()
  func didTapCancelButtonAtResign()
}

final class ResignCoordinator: Coordinator {
  weak var listener: ResignListener?
  
  private let viewController: ResignViewController
  private let viewModel: ResignViewModel
  
  init(
    viewModel: ResignViewModel
  ) {
    self.viewModel = viewModel
    self.viewController = ResignViewController(viewModel: viewModel)
    
    super.init()
    viewModel.coodinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
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
