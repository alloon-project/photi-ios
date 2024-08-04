//
//  SettingViewController.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class SettingViewController: UIViewController {
  // MARK: - Variables
  private let menuDatasource = [("프로필 수정", 0),
                                ("문의하기", 0),
                                ("서비스 이용약관", 0),
                                ("개인정보 처리방침", 0),
                                ("버전정보", 1),
                                ("로그아웃", 0)]
  // MARK: - UIComponents
  private let navigationBar = PrimaryNavigationView(textType: .center, iconType: .one, colorType: .dark, titleText: "설정")
  private let menuTableView = {
    let tableView = SelfSizingTableView()
    tableView.registerCell(SettingNaviagationTableViewCell.self)
    tableView.registerCell(SettingVersionTableViewCell.self)
    tableView.estimatedRowHeight = 32
    
    return tableView
  }()
  
  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    menuTableView.delegate = self
    menuTableView.dataSource = self
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
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(20)
    }
  }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    56
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    menuDatasource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if menuDatasource[indexPath.row].1 == 0 {
      let cell = tableView.dequeueCell(SettingNaviagationTableViewCell.self, for: indexPath)
      cell.configure(with: menuDatasource[indexPath.row].0)
      return cell
    } else {
      let cell = tableView.dequeueCell(SettingVersionTableViewCell.self, for: indexPath)
      if let currentVerison = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        cell.configure(with: menuDatasource[indexPath.row].0, version: currentVerison)
      } else {
        cell.configure(with: menuDatasource[indexPath.row].0, version: "버전 확인 불가")
      }
      return cell
    }
  }
}
