//
//  SettingCoordinator.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

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
  
  private let inquiryContainable: InquiryContainable
  private var inquiryCoordinator: Coordinating?
  
  init(
    viewModel: SettingViewModel,
    profileEditContainable: ProfileEditContainable,
    inquiryContainable: InquiryContainable
  ) {
    self.viewModel = viewModel
    
    self.profileEditContainable = profileEditContainable
    self.inquiryContainable = inquiryContainable
    self.viewController = SettingViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  // MARK: - ProfileEdit
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
    guard inquiryCoordinator == nil else { return }
    
    let coordinater = inquiryContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.inquiryCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachInquiry() {
    guard let coordinator = inquiryCoordinator else { return }
    
    removeChild(coordinator)
    self.inquiryCoordinator = nil
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - ServiceTerms
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

// MARK: - InquiryListener
extension SettingCoordinator: InquiryListener {
  func didTapBackButtonAtInquiry() {
    detachInquiry()
  }
}
