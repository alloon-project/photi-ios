//
//  ProfileEditViewController.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import PhotosUI
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
  private let didSelectImageRelay = PublishRelay<UIImageWrapper>()

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
  
  private let successUpdateProfileImageToastView = ToastView(
    tipPosition: .none,
    text: "프로필 사진이 업데이트됐어요.",
    icon: .bulbWhite
  )
  
  private let failedUpdateProfileImageToastView = ToastView(
    tipPosition: .none,
    text: "수정에 실패했어요.다시 시도해주세요.",
    icon: .closeRed
  )
  
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
    
    [successUpdateProfileImageToastView, failedUpdateProfileImageToastView].forEach {
      $0.setConstraints {
        $0.centerX.equalToSuperview()
        $0.bottom.equalToSuperview().inset(64)
      }
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
      requestData: requestData.asSignal(),
      didSelectImage: didSelectImageRelay.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(output: output)
  }
  
  func viewBind() {
    profileImageView.rx.tapGesture()
      .when(.recognized)
      .bind(with: self) { owner, _ in
        owner.presentImagePicker()
      }
      .disposed(by: disposeBag)
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
    
    output.isSuccessedUploadImage
      .emit(with: self) { owner, isSuccess in
        LoadingAnimation.logo.stop()
        owner.presentToastView(isSuccess: isSuccess)
      }
      .disposed(by: disposeBag)
    
    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
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

// MARK: - PHPickerViewControllerDelegate
extension ProfileEditViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)

    guard
      let itemProvider = results.first?.itemProvider,
      itemProvider.canLoadObject(ofClass: UIImage.self)
    else { return }

    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
      guard let self, let image = image as? UIImage else { return }
      DispatchQueue.main.async {
        LoadingAnimation.logo.start(at: self.view)
      }
      self.didSelectImageRelay.accept(.init(image: image))
    }
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
  
  func presentImagePicker() {
    var configuration = PHPickerConfiguration(photoLibrary: .shared())
    configuration.selectionLimit = 1
    configuration.filter = .images
    
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = self
    present(picker, animated: true)
  }
  
  func presentToastView(isSuccess: Bool) {
    isSuccess ?
    successUpdateProfileImageToastView.present(at: self.view) :
    failedUpdateProfileImageToastView.present(at: self.view)
  }
}
