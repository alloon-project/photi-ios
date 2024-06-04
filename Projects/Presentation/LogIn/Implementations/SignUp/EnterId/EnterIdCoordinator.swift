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
  func didFinishAtEnterId()
}

final class EnterIdCoordinator: Coordinator, EnterIdCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtEnterId()
  }
  
  func didTapNextButton() {
    listener?.didFinishAtEnterId()
  }
  
  weak var listener: EnterIdListener?
  
  private let viewController: EnterIdViewController
  private let viewModel: EnterIdViewModel
  
  init(viewModel: EnterIdViewModel) {
    self.viewModel = EnterIdViewModel()
    self.viewController = EnterIdViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
