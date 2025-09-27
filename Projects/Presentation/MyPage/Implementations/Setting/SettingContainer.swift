//
//  SettingContainer.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Coordinator
import LogIn
import UseCase
import Report

protocol SettingDependency {
  var profileEditUseCase: ProfileEditUseCase { get }
  var reportContainable: ReportContainable { get }
  var resetPasswordContainable: ResetPasswordContainable { get }
  var myPageUseCase: MyPageUseCase { get }
}

protocol SettingContainable: Containable {
  func coordinator(listener: SettingListener) -> ViewableCoordinating
}

final class SettingContainer:
  Container<SettingDependency>,
  SettingContainable,
  ProfileEditDependency {
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  var resetPasswordContainable: ResetPasswordContainable { dependency.resetPasswordContainable }
  
  func coordinator(listener: SettingListener) -> ViewableCoordinating {
    let viewModel = SettingViewModel(useCase: dependency.myPageUseCase)
    let viewControllerable = SettingViewController(viewModel: viewModel)
    
    let profileEdit = ProfileEditContainer(dependency: self)
    
    let coordinator = SettingCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      profileEditContainable: profileEdit,
      reportContainable: dependency.reportContainable
    )
    
    coordinator.listener = listener
    
    return coordinator
  }
}
