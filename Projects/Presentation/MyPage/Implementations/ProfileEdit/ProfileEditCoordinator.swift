//
//  ProfileEditCoordinator.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core
import MyPage

protocol ProfileEditViewModelable { }

public protocol ProfileEditListener: AnyObject { }

final class ProfileEditCoordinator: Coordinator, ProfileEditCoordinatable {
  weak var listener: ProfileEditListener?
  
  private let viewController: ProfileEditViewController
  private let viewModel: ProfileEditViewModel

  init(viewModel: ProfileEditViewModel) {
    self.viewModel = viewModel
    self.viewController = ProfileEditViewController()
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
