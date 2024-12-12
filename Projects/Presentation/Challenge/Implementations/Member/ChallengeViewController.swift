//
//  ChallengeViewController.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Core
import DesignSystem

final class ChallengeViewController: UIViewController, CameraRequestable {
  // MARK: - Properties
  private let viewModel: ChallengeViewModel
  private let disposeBag = DisposeBag()
  private var segmentIndex: Int = 0
  
  // MARK: - UI Components
  private var segmentViewControllers = [UIViewController]()
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    rigthItems: [.shareButton, .optionButton],
    displayMode: .white
  )
  private let titleView = ChallengeTitleView()
  private let segmentControl = PhotiSegmentControl(items: ["피드", "소개", "파티원"])
  private let mainContentScrollView = UIScrollView()
  private let mainContentView = UIView()
  private let cameraShutterButton: UIButton = {
    let button = UIButton()
    button.setImage(.shutterWhite, for: .normal)
    
    return button
  }()
  
  // MARK: - Initializers
  init(viewModel: ChallengeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let tipView = ToastView(
      tipPosition: .centerBottom,
      text: "오늘의 인증이 완료되지 않았어요!",
      icon: .bulbWhite
    )
    
    tipView.setConstraints { [weak self] make in
      guard let self else { return }
      make.bottom.equalTo(cameraShutterButton.snp.top).offset(-6)
      make.centerX.equalToSuperview()
    }
    
    tipView.present(to: self)
  }
}

// MARK: - UI Methods
private extension ChallengeViewController {
  func setupUI() {
    setViewHierarhcy()
    setConstraints()
  }
  
  func setViewHierarhcy() {
    view.addSubviews(
      titleView,
      navigationBar,
      segmentControl,
      mainContentScrollView,
      cameraShutterButton
    )
    mainContentScrollView.addSubview(mainContentView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    titleView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(300)
    }
    
    segmentControl.snp.makeConstraints {
      $0.bottom.equalTo(titleView)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(38)
    }
    
    mainContentScrollView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.top.equalTo(segmentControl.snp.bottom)
    }

    mainContentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
    }
    
    cameraShutterButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(64)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(22)
    }
  }
}

// MARK: - Bind
private extension ChallengeViewController {
  func bind() {
    viewBind()
  func viewBind() {
    cameraShutterButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.requestOpenCamera(delegate: owner)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - ChallengePresentable
extension ChallengeViewController: ChallengePresentable {
  func attachViewControllers(_ viewControllers: UIViewController...) {
    segmentViewControllers = viewControllers

    attachViewController(segmentIndex: segmentIndex)
  }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ChallengeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      picker.dismiss(animated: true)
      return
    }
    picker.dismiss(animated: true)
    
    let popOver = UploadPhotoPopOverViewController(type: .two, image: image)
    popOver.present(to: self, animated: true)
    popOver.delegate = self
  }
}

// MARK: - UploadPhotoPopOverDelegate
extension ChallengeViewController: UploadPhotoPopOverDelegate {
  func upload(_ popOver: UploadPhotoPopOverViewController, image: UIImage) {
    print(image.size)
  }
}

// MARK: - Private Methods
// TODO: - 네이밍 수정
private extension ChallengeViewController {
  func updateSegmentViewController(to index: Int) {
    defer { segmentIndex = index }
    removeViewController(segmentIndex: segmentIndex)
    attachViewController(segmentIndex: index)
  }
  
  func removeViewController(segmentIndex: Int) {
    guard segmentViewControllers.count > segmentIndex else { return }
    
    let viewController = segmentViewControllers[segmentIndex]
    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
    viewController.didMove(toParent: nil)
  }
  
  func attachViewController(segmentIndex: Int) {
    guard segmentViewControllers.count > segmentIndex else { return }
    
    let viewController = segmentViewControllers[segmentIndex]
    viewController.willMove(toParent: self)
    addChild(viewController)
    viewController.didMove(toParent: self)
    mainContentView.addSubview(viewController.view)
    viewController.view.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
