//
//  SettingCoordinator.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import Report

protocol SettingListener: AnyObject {
  func didTapBackButtonAtSetting()
}

protocol SettingPresentable { }

final class SettingCoordinator: ViewableCoordinator<SettingPresentable> {
  weak var listener: SettingListener?

  private let viewModel: SettingViewModel
  
  private let profileEditContainable: ProfileEditContainable
  private var profileEditCoordinator: ViewableCoordinating?
  
  private let reportContainable: ReportContainable
  private var reportCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: SettingViewModel,
    profileEditContainable: ProfileEditContainable,
    reportContainable: ReportContainable
  ) {
    self.viewModel = viewModel
    
    self.profileEditContainable = profileEditContainable
    self.reportContainable = reportContainable
    
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  // MARK: - Profile Edit
  func attachProfileEdit() {
    guard profileEditCoordinator == nil else { return }
    
    let coordinater = profileEditContainable.coordinator(listener: self)
    addChild(coordinater)
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.profileEditCoordinator = coordinater
  }
  
  func detachProfileEdit() {
    guard let coordinator = profileEditCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.profileEditCoordinator = nil
  }
  
  // MARK: - Inquiry
  func attachInquiry() {
    guard reportCoordinator == nil else { return }
    
    let coordinator = reportContainable.coordinator(listener: self, reportType: .inquiry)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.reportCoordinator = coordinator
  }
  
  func detachInquiry() {
    guard let coordinator = reportCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.reportCoordinator = nil
  }
  
  // MARK: - Service Term
  func attachServiceTerms() {}
  
  func detachServiceTerms() {}
  
  // MARK: - Privacy
  func attachPrivacy() {}
  
  func detachPrivacy() {}
}

// MARK: - Coordinatable
extension SettingCoordinator: SettingCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtSetting()
  }
}
// MARK: - ProfileEditListener
extension SettingCoordinator: ProfileEditListener {
  func didTapBackButtonAtProfileEdit() {
    detachProfileEdit()
  }
}

// MARK: - Report
extension SettingCoordinator: ReportListener {
  func detachReport() {
    detachInquiry()
  }
}
