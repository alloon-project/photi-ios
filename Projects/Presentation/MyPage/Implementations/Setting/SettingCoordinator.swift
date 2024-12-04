//
//  SettingCoordinator.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core
import Report

protocol SettingViewModelable { }

public protocol SettingListener: AnyObject {
  func didTapBackButtonAtSetting()
}

final class SettingCoordinator: Coordinator {
  weak var listener: SettingListener?
  
  private let viewController: SettingViewController
  private let viewModel: SettingViewModel
  
  private let profileEditContainable: ProfileEditContainable
  private var profileEditCoordinator: Coordinating?
  
  private let reportContainable: ReportContainable
  private var reportCoordinator: Coordinating?
  
  init(
    viewModel: SettingViewModel,
    profileEditContainable: ProfileEditContainable,
    reportContainable: ReportContainable
  ) {
    self.viewModel = viewModel
    
    self.profileEditContainable = profileEditContainable
    self.reportContainable = reportContainable
    
    self.viewController = SettingViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  // MARK: - Profile Edit
  func attachProfileEdit() {
    guard profileEditCoordinator == nil else { return }
    
    let coordinater = profileEditContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.profileEditCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachProfileEdit() {
    guard let coordinator = profileEditCoordinator else { return }
    
    removeChild(coordinator)
    self.profileEditCoordinator = nil
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Inquiry
  func attachInquiry() {
    guard reportCoordinator == nil else { return }
    
    let coordinator = reportContainable.coordinator(listener: self, reportType: .INQUIRY)
    addChild(coordinator)
    
    self.reportCoordinator = coordinator
    coordinator.start(at: self.navigationController)
  }
  
  func detachInquiry() {
    guard let coordinator = reportCoordinator else { return }
    
    removeChild(coordinator)
    self.reportCoordinator = nil
    navigationController?.popViewController(animated: true)
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
