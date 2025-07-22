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
  func didFinishWithdrawal()
  func didTapBackButtonAtSetting()
  func authenticatedFailedAtSetting()
  func didLogOut()
}

protocol SettingPresentable {
  func presentInquiryApplicated()
}

final class SettingCoordinator: ViewableCoordinator<SettingPresentable> {
  weak var listener: SettingListener?

  private let viewModel: SettingViewModel
  
  private let profileEditContainable: ProfileEditContainable
  private var profileEditCoordinator: ViewableCoordinating?
  
  private let reportContainable: ReportContainable
  private var reportCoordinator: ViewableCoordinating?
  
  private let webViewContainable: WebViewContainable
  private var webViewCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: SettingViewModel,
    profileEditContainable: ProfileEditContainable,
    reportContainable: ReportContainable,
    webViewContainable: WebViewContainable
  ) {
    self.viewModel = viewModel
    
    self.profileEditContainable = profileEditContainable
    self.reportContainable = reportContainable
    self.webViewContainable = webViewContainable
    
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
  func attachServiceTerms() {
    guard webViewCoordinator == nil else { return }
    let termUrl = "https://octagonal-caboc-47d.notion.site/f1dc17026f884c2ebe90437b0ee9fa63?pvs=143"
    let coordinator = webViewContainable.coordinator(
      listener: self,
      url: termUrl
    )
    addChild(coordinator)
    viewControllerable.present(
      coordinator.viewControllerable,
      animated: true,
      modalPresentationStyle: .pageSheet
    )
    
    self.reportCoordinator = coordinator
  }
  
  // MARK: - Privacy
  func attachPrivacy() {
    guard webViewCoordinator == nil else { return }
    let privacyUrl = "https://octagonal-caboc-47d.notion.site/16c7071e9b43802fac6beedbac719400?pvs=143"
    let coordinator = webViewContainable.coordinator(
      listener: self,
      url: privacyUrl
    )
    addChild(coordinator)
    viewControllerable.present(
      coordinator.viewControllerable,
      animated: true,
      modalPresentationStyle: .pageSheet
    )
    
    self.reportCoordinator = coordinator
  }
}

// MARK: - Coordinatable
extension SettingCoordinator: SettingCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtSetting()
  }
  
  func didFinishLogOut() {
    listener?.didLogOut()
  }
}
// MARK: - ProfileEditListener
extension SettingCoordinator: ProfileEditListener {
  func didFinishWithdrawal() {
    listener?.didFinishWithdrawal()
  }
  
  func didTapBackButtonAtProfileEdit() {
    detachProfileEdit()
  }
  
  func authenticatedFailedAtProfileEdit() {
    listener?.authenticatedFailedAtSetting()
  }
}

// MARK: - Report
extension SettingCoordinator: ReportListener {
  func didInquiryApplicated() {
    detachInquiry()
    presenter.presentInquiryApplicated()
  }
  
  func detachReport() {
    detachInquiry()
  }
}

// MAKR: - WebView
extension SettingCoordinator: WebViewListener {}
