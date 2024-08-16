//
//  ProfileEditViewController.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Core
import DesignSystem

final class ProfileEditViewController: UIViewController {
  private let disposeBag = DisposeBag()
  // MARK: - UIComponents
  private let navigationBar = PrimaryNavigationView(textType: .center,
                                                    iconType: .one,
                                                    colorType: .dark,
                                                    titleText: "프로필 수정")
  
  private let profileImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 48
    imageView.backgroundColor = .gray400
    imageView.clipsToBounds = true
    
    return imageView
  }()
  
  private let menuTableView = {
    let tableView = SelfSizingTableView()
    tableView.registerCell(SettingTableViewCell.self)
    tableView.estimatedRowHeight = 32
    tableView.isScrollEnabled = false
    
    return tableView
  }()
  
  private let withdrawButton = {
    let button = TextButton(text: "회원탈퇴", 
                            size: .small,
                            type: .gray)
    
    return button
  }()
  
  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    menuTableView.rx.setDelegate(self).disposed(by: disposeBag)
    menuTableView.rx.setDataSource(self).disposed(by: disposeBag)
    setupUI()
    bind()
  }
}

// MARK: - Private methods
private extension ProfileEditViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func bind() {}
  
  func setViewHierarchy() {
    self.view.addSubviews(navigationBar,
                          profileImageView,
                          menuTableView,
                          withdrawButton)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(44)
      $0.height.equalTo(56)
    }
    
    profileImageView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(navigationBar.snp.bottom).offset(32)
      $0.width.height.equalTo(96)
    }
    
    menuTableView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(profileImageView.snp.bottom).offset(32)
      $0.height.equalTo(184)
    }
    
    withdrawButton.snp.makeConstraints {
      $0.top.equalTo(menuTableView.snp.bottom).offset(32)
      $0.trailing.equalToSuperview().offset(-14)
    }
  }
}

extension ProfileEditViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    56
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    profileEditMenuDataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(SettingTableViewCell.self, for: indexPath)
    
    if profileEditMenuDataSource[indexPath.row].1 == 0 {
      cell.configure(with: profileEditMenuDataSource[indexPath.row].0)
    } else {
      cell.configure(with: profileEditMenuDataSource[indexPath.row].0,
                     type: .label(text: "불러오는중")) // TODO: - 아이디 & 이메일 조회 후 변경 예정
    }
    return cell
  }
}
