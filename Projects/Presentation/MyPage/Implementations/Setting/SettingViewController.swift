//
//  SettingViewController.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class SettingViewController: UIViewController, ViewControllerable {
  private let viewModel: SettingViewModel
  
  // MARK: - Variables
  private var disposeBag = DisposeBag()
  
  // MARK: - UIComponents
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    title: "설정",
    displayMode: .dark
  )
  
  private let menuTableView = {
    let tableView = SelfSizingTableView()
    tableView.registerCell(SettingTableViewCell.self)
    tableView.estimatedRowHeight = 32
    tableView.isScrollEnabled = false
    
    return tableView
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
    
    menuTableView.rx.setDataSource(self).disposed(by: disposeBag)
    menuTableView.rx.setDelegate(self).disposed(by: disposeBag)
    setupUI()
    bind()
  }
}

// MARK: - Private methods
private extension SettingViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func bind() {
    let input = SettingViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      didTapCell: menuTableView.rx.itemSelected
    )
    
    let _ = viewModel.transform(input: input)
  }
  
  func setViewHierarchy() {
    self.view.addSubviews(navigationBar, menuTableView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(44)
      $0.height.equalTo(56)
    }
    
    menuTableView.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
      $0.top.equalTo(navigationBar.snp.bottom).offset(20)
      $0.bottom.equalToSuperview().offset(-20)
    }
  }
}

// MARK: - SettingPresentable
extension SettingViewController: SettingPresentable { }

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    56
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    settingMenuDatasource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(SettingTableViewCell.self, for: indexPath)
    if settingMenuDatasource[indexPath.row].1 == 0 {
      cell.configure(
        with: settingMenuDatasource[indexPath.row].0,
        type: .default
      )
    } else {
      if let currentVerison = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        cell.configure(
          with: settingMenuDatasource[indexPath.row].0,
          type: .label(text: currentVerison),
          font: .caption1,
          rightTextColor: .blue500
        )
      } else {
        cell.configure(
          with: settingMenuDatasource[indexPath.row].0,
          type: .label(text: "버전 확인 불가"),
          font: .caption1,
          rightTextColor: .blue500
        )
      }
    }
    return cell
  }
}
