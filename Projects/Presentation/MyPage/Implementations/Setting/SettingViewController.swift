//
//  SettingViewController.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import SnapKit
import Core
import CoreUI
import DesignSystem

final class SettingViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private var cancellables = Set<AnyCancellable>()
  private let viewModel: SettingViewModel
  private var settingMenuItems = [SettingMenuItem]() {
    didSet { menuTableView.reloadData() }
  }
  
  private let requestData = PassthroughSubject<Void, Never>()
  private let didTapSettingMenu = PassthroughSubject<SettingMenuItem, Never>()
  private let requestLogOut = PassthroughSubject<Void, Never>()

  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, title: "설정", displayMode: .dark)
  
  private let menuTableView: SelfSizingTableView = {
    let tableView = SelfSizingTableView()
    tableView.registerCell(SettingTableViewCell.self)
    tableView.rowHeight = 56
    tableView.separatorInset = .zero
    tableView.separatorColor = .gray200
    tableView.isScrollEnabled = false
    
    return tableView
  }()
  
  private let logOutAlertView: AlertViewController = {
    let alert = AlertViewController(alertType: .canCancel, title: "정말 로그아웃 하시겠어요?")
    alert.confirmButtonTitle = "로그아웃 할게요"
    alert.cancelButtonTitle = "취소할게요"
    
    return alert
  }()
  
  // MARK: - Initializers
  init(viewModel: SettingViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    menuTableView.delegate = self
    menuTableView.dataSource = self
    setupUI()
    bind()
    
    requestData.send(())
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideTabBar(animated: true)
  }
}

// MARK: - UI Methods
private extension SettingViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, menuTableView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(44)
      $0.height.equalTo(56)
    }
    
    menuTableView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(20)
    }
  }
}

// MARK: - Bind Methods
private extension SettingViewController {
  func bind() {
    let backButtonEvent = navigationBar.didTapBackButton
    
    let input = SettingViewModel.Input(
      didTapBackButton: backButtonEvent.eraseToAnyPublisher(),
      requestData: requestData.eraseToAnyPublisher(),
      didTapSettingMenu: didTapSettingMenu.eraseToAnyPublisher(),
      requestLogOut: requestLogOut.eraseToAnyPublisher()
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(for: output)
  }
  
  func viewBind() {
    logOutAlertView.didTapConfirmButton
      .sinkOnMain(with: self) { owner, _ in
        owner.requestLogOut.send(())
      }.store(in: &cancellables)
  }
  
  func bind(for output: SettingViewModel.Output) {
    output.settingMenuItems
      .sinkOnMain(with: self) { owner, items in
        owner.settingMenuItems = items
      }
      .store(in: &cancellables)
    
    output.shouldPresentLogoutAlert
      .sinkOnMain(with: self) { owner, _ in
        owner.logOutAlertView.present(to: owner, animted: true)
      }
      .store(in: &cancellables)
    
    output.presentPrivacyPolicy
      .sinkOnMain(with: self) { owner, _ in
        owner.presentPrivacyPolicyWebView()
      }
      .store(in: &cancellables)
    
    output.presentServiceTerms
      .sinkOnMain(with: self) { owner, _ in
        owner.presentServiceTermsWebView()
      }
      .store(in: &cancellables)
  }
}

// MARK: - SettingPresentable
extension SettingViewController: SettingPresentable {
  func presentInquiryApplicated() {
    let toastText = "접수가 완료됐어요. 꼼꼼히 확인 후,\n회원님의 이메일로 답변을 보내드릴게요."
    let toastView = ToastView(tipPosition: .none, text: toastText, icon: .bulbWhite)
    toastView.setConstraints {
      $0.bottom.equalToSuperview().inset(64)
      $0.centerX.equalToSuperview()
    }
    
    toastView.present(to: self)
  }
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settingMenuItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(SettingTableViewCell.self, for: indexPath)
    cell.configure(with: settingMenuItems[indexPath.row])
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = settingMenuItems[indexPath.row]
    didTapSettingMenu.send(item)
  }
}

// MARK: - Private Methods
private extension SettingViewController {
  func presentPrivacyPolicyWebView() {
    let privacyUrl = ServiceConfiguration.shared.privacyUrl
    presentWebView(with: privacyUrl)
  }
  
  func presentServiceTermsWebView() {
    let serviceTermsUrl = ServiceConfiguration.shared.termsUrl
    presentWebView(with: serviceTermsUrl)
  }
  
  func presentWebView(with url: URL) {
    let webviewController = WebViewController(url: url)
    webviewController.modalPresentationStyle = .pageSheet
    present(webviewController, animated: true)
  }
}
