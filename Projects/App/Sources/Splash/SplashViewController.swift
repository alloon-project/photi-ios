//
//  SplashViewController.swift
//  Photi-DEV
//
//  Created by jung on 8/14/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import DesignSystem

final class SplashViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let viewModel: SplashViewModel
  private let logoImageView = UIImageView(image: .logo)
  private let animation = LoadingAnimation.logo
  private let forceUpdateAlert: AlertViewController = {
    let alertVC = AlertViewController(
      alertType: .canCancel,
      title: "업데이트가 필요해요",
      subTitle: "최신 버전 업데이트를 위해\n스토어로 이동합니다.",
      shouldDismissOnConfirm: false
    )
    alertVC.confirmButtonTitle = "스토어 바로가기"
    alertVC.cancelButtonTitle = "닫기"
    
    return alertVC
  }()
  
  // MARK: - Initialiers
  init(viewModel: SplashViewModel) {
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
    bind()
  }
}

// MARK: - UI Methods
private extension SplashViewController {
  func setupUI() {
    view.backgroundColor = .blue400
    view.addSubview(logoImageView)
    logoImageView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.height.equalTo(160)
    }
  }
}

// MARK: - Bind Methods
private extension SplashViewController {
  func bind() {
    let input = SplashViewModel.Input()
    let output = viewModel.transform(input: input)
    
    output.requiredForceUpdate
      .emit(with: self) { owner, _ in
        owner.presentRequiredForceUpdateAlert()
      }
      .disposed(by: disposeBag)
    
    forceUpdateAlert.rx.didTapConfirmButton
      .bind(with: self) { owner, _ in
        owner.openAppStoreToUpdate()
      }
      .disposed(by: disposeBag)
    
    forceUpdateAlert.rx.didTapCancelButton
      .bind(with: self) { owner, _ in
        owner.forceTerminateApp()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Methods
private extension SplashViewController {
  func presentRequiredForceUpdateAlert() {
      forceUpdateAlert.present(to: self, animted: true)
  }
  
  func openAppStoreToUpdate() {
    guard let appId = Bundle.main.infoDictionary?["AppleAppID"] as? String else { return forceTerminateApp() } // 강제 종료
    
    let urlString = "itms-apps://itunes.apple.com/app/\(appId)"
    
    guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else { return forceTerminateApp() }
    
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
  }
  
  func forceTerminateApp() {
    exit(0)
  }
}
