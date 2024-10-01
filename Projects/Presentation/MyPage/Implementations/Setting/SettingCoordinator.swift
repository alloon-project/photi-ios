//
//  SettingCoordinator.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core
import MyPage
import Report

protocol SettingViewModelable { }

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
    
    let reportData = ReportDataSource(
      title: "문의 내용이 무엇인가요?",
      contents: ["서비스 이용 문의",
                 "개선 / 제안 요청",
                 "오류 문의",
                 "기타 문의"],
      textViewTitle: "자세한 내용을 적어주세요",
      textViewPlaceholder: "문의 내용을 상세히 알려주세요",
      buttonTitle: "제출하기"
    )
    
    let coordinater = reportContainable.coordinator(listener: self, reportData: reportData)
    addChild(coordinater)
    
    self.reportCoordinator = coordinater
    coordinater.start(at: self.navigationController)
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
extension SettingCoordinator: ProfileEditListener {}

// MARK: - Report
extension SettingCoordinator: ReportListener {
  func detachReport() {
    self.detachInquiry()
  }
}
