//
//  EnterIdCoordinator.swift
//  LogInImpl
//
//  Created by jung on 6/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

protocol EnterIdViewModelable { }

protocol EnterIdListener: AnyObject {
  func didTapBackButtonAtEnterId()
  func didFinishEnterId()
}

final class EnterIdCoordinator: Coordinator, EnterIdCoordinatable {
  weak var listener: EnterIdListener?
  
  private let viewController: EnterIdViewController
  private let viewModel: EnterIdViewModel
  
  init(viewModel: EnterIdViewModel) {
    self.viewModel = viewModel
    self.viewController = EnterIdViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  func didTapBackButton() {
    listener?.didTapBackButtonAtEnterId()
  }
  
  func didTapNextButton() {
    listener?.didFinishEnterId()
  }
}
