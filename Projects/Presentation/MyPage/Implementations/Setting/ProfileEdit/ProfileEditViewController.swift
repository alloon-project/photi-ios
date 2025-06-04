//
//  ProfileEditViewController.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ProfileEditViewController: UIViewController, ViewControllerable {
  private let viewModel: ProfileEditViewModel
  private let disposeBag = DisposeBag()
  private var menuItems = [ProfileEditMenuItem]() {
    didSet { menuTableView.reloadData() }
  }
  
  private let requestData = PublishRelay<Void>()
  private let didTapProfileEditMenu = PublishRelay<ProfileEditMenuItem>()

  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, title: "프로필 수정", displayMode: .dark)
  
  private let profileImageView = AvatarImageView(size: .large)
  
  private let menuTableView: SelfSizingTableView = {
    let tableView = SelfSizingTableView()
    tableView.registerCell(ProfileEditMenuItemCell.self)
    tableView.rowHeight = 56
    tableView.separatorInset = .zero
    tableView.separatorColor = .gray200
    tableView.isScrollEnabled = false
    
    return tableView
  }()
  private let resignButton = TextButton(text: "회원탈퇴", size: .small, type: .gray)
  
  // MARK: - Initializers
  init(viewModel: ProfileEditViewModel) {
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
    
    requestData.accept(())
  }
}

// MARK: - UI Methods
private extension ProfileEditViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      profileImageView,
      menuTableView,
      resignButton
    )
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
    }
    
    menuTableView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(profileImageView.snp.bottom).offset(32)
    }
    
    resignButton.snp.makeConstraints {
      $0.top.equalTo(menuTableView.snp.bottom).offset(32)
      $0.trailing.equalToSuperview().inset(24)
    }
  }
}

// MARK: - Bind
private extension ProfileEditViewController {
  func bind() {
    let input = ProfileEditViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton.asSignal(),
      didTapProfileEditMenu: didTapProfileEditMenu.asSignal(),
      didTapResignButton: resignButton.rx.tap.asSignal(),
      requestData: requestData.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    bind(output: output)
  }
  
  func bind(output: ProfileEditViewModel.Output) {
    output.profileEditMenuItemsRelay
      .drive(rx.menuItems)
      .disposed(by: disposeBag)
    
    output.profileImageUrl
      .drive(with: self) { owner, url in
        Task {
          let image = await owner.profileImage(with: url)
          owner.profileImageView.configureImage(image)
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - ProfileEditPresentable
extension ProfileEditViewController: ProfileEditPresentable {
  func displayToastView() {
    let changedPasswordToastView = ToastView(
      tipPosition: .none,
      text: "비밀번호 변경이 완료됐어요",
      icon: .bulbWhite
    )
    changedPasswordToastView.setConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(64)
    }
    
    changedPasswordToastView.present(to: self)
  }
}

// MARK: - UITableViewDataSource
extension ProfileEditViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menuItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    print(menuItems)
    let cell = tableView.dequeueCell(ProfileEditMenuItemCell.self, for: indexPath)
    cell.configure(with: menuItems[indexPath.row])
    return cell
  }
}

// MARK: - UITableViewDelegate
extension ProfileEditViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = menuItems[indexPath.row]
    didTapProfileEditMenu.accept(item)
  }
}

// MARK: - Private Methods
private extension ProfileEditViewController {
  func profileImage(with url: URL?) async -> UIImage? {
    guard let url = url else { return nil }
    
    return await withCheckedContinuation { continuation in
      KingfisherManager.shared.retrieveImage(with: url) { result in
        switch result {
        case .success(let value):
          continuation.resume(returning: value.image)
        case .failure:
          continuation.resume(returning: nil)
        }
      }
    }
  }
}
