//
//  AppViewController.swift
//  Alloon-DEV
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class AppViewController: UITabBarController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: AppViewModel
  private let didTapMyPageTabBarItem = PublishRelay<Void>()
  private let didTapLogInButton = PublishRelay<Void>()
  private var homeNavigationController: UIViewController?
  
  private let tapMyPageWithoutLogInAlertView: AlertViewController = {
    let alertVC = AlertViewController(
      alertType: .canCancel,
      title: "로그인하고 다양한 챌린지에\n참여해보세요!"
    )
    alertVC.confirmButtonTitle = "로그인하기"
    alertVC.cancelButtonTitle = "나중에 할래요"
    
    return alertVC
  }()
  
  private let tokenExpiredAlertView: AlertViewController = {
    let alertVC = AlertViewController(
      alertType: .canCancel,
      title: "재로그인이 필요해요",
      subTitle: "보안을 위해 자동 로그아웃 됐어요.\n다시 로그인해주세요."
    )
    alertVC.confirmButtonTitle = "로그인하기"
    alertVC.cancelButtonTitle = "나중에 할래요"
    
    return alertVC
  }()
  
  // MARK: - Initializers
  init(viewModel: AppViewModel) {
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
    
    delegate = self
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    tabBar.frame.size.height = 64 + UIView.safeAreaInset.bottom
    tabBar.frame.origin.y = view.frame.height - tabBar.frame.size.height
    tabBar.itemPositioning = .centered
    tabBar.itemWidth = 46
    tabBar.itemSpacing = 67
  }
}

// MARK: - Bind Methods
private extension AppViewController {
  func bind() {
    let input = AppViewModel.Input(
      didTapMyPageTabBarItem: didTapMyPageTabBarItem.asSignal(),
      didTapLogInButton: didTapLogInButton.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    
    output.allowMoveToMyPage
      .emit(with: self) { owner, _ in
        owner.selectedIndex = 2
      }
      .disposed(by: disposeBag)
    
    tapMyPageWithoutLogInAlertView.rx.didTapConfirmButton
      .bind(with: self) { owner, _ in
        owner.didTapLogInButton.accept(())
      }
      .disposed(by: disposeBag)
    
    tokenExpiredAlertView.rx.didTapConfirmButton
      .bind(with: self) { owner, _ in
        owner.didTapLogInButton.accept(())
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - AppPresentable
extension AppViewController: AppPresentable {
  func attachNavigationControllers(_ navigationControllers: NavigationControllerable...) {
    let navigations = navigationControllers.map(\.navigationController)
    homeNavigationController = navigations.first
    navigations.forEach {
      $0.interactivePopGestureRecognizer?.isEnabled = false
      $0.isNavigationBarHidden = true
    }
    
    setViewControllers(navigations, animated: false)
    setTapBarItems()
  }
  
  func changeNavigationControllerToHome() {
    guard viewControllers != nil else { return }
    selectedIndex = 0 // 첫 번째 탭으로 전환
    
    guard let viewController = viewControllers?.first else { return }
    viewController.showTabBar(animted: true)
  }
  
  func presentWelcomeToastView(_ username: String) {
    bulbToastView(title: "\(username)님 환영합니다!").present(at: self.view)
  }
  
  func presentTokenExpiredAlertView(to navigationControllerable: NavigationControllerable) {
    guard !tokenExpiredAlertView.isPresenting else { return }
    
    tokenExpiredAlertView.present(to: navigationControllerable.navigationController, animted: true)
  }
  
  func presentTabMyPageWithoutLogInAlertView(to navigationControllerable: NavigationControllerable) {
    guard !tapMyPageWithoutLogInAlertView.isPresenting else { return }
    
    tapMyPageWithoutLogInAlertView.present(to: navigationControllerable.navigationController, animted: true)
  }
  
  func presentLogOutToastView(to navigationControllerable: NavigationControllerable) {
    bulbToastView(title: "로그아웃이 완료됐어요.").present(at: self.view)
  }
  
  func presentWithdrawToastView(to navigationControllerable: NavigationControllerable) {
    bulbToastView(title: "탈퇴가 완료됐어요. 다음에 또 만나요!").present(at: self.view)
  }
}

// MARK: - UI Methods
private extension AppViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    tabBar.backgroundColor = .white
    
    // tabBar Border Setting
    tabBar.layer.borderWidth = 1
    tabBar.layer.borderColor = UIColor.gray200.cgColor
    tabBar.layer.cornerRadius = 16
    
    // tabBar AttributedText Setting
    let appearance = UITabBarItem.appearance()
    let normalAttributes = NSAttributedString.attributes(font: .caption1Bold, color: .gray400)
    let selectedAttributes = NSAttributedString.attributes(font: .caption1Bold, color: .blue500)
    
    appearance.setTitleTextAttributes(normalAttributes, for: .normal)
    appearance.setTitleTextAttributes(selectedAttributes, for: .selected)
  }
  
  func setTapBarItems() {
    guard let items = tabBar.items, items.count == 3 else { return }
    items[0].selectedImage = .homeBlue.withRenderingMode(.alwaysOriginal)
    items[0].image = .homeGray400.withRenderingMode(.alwaysOriginal)
    items[0].title = "홈"
    
    items[1].selectedImage = .postitBlue.withRenderingMode(.alwaysOriginal)
    items[1].image = .postitGray400.withRenderingMode(.alwaysOriginal)
    items[1].title = "챌린지"
    
    items[2].selectedImage = .userBlue.withRenderingMode(.alwaysOriginal)
    items[2].image = .userGray400.withRenderingMode(.alwaysOriginal)
    items[2].title = "마이"
  }
}

// MARK: - UITabBarControllerDelegate
extension AppViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    guard let viewControllers = tabBarController.viewControllers else { return false }
    guard let selectedIndex = viewControllers.firstIndex(of: viewController) else { return false }
    if selectedIndex == 2 && self.selectedIndex != 2 { didTapMyPageTabBarItem.accept(()) }
    return selectedIndex != 2
  }
}

// MARK: - Private Methods
private extension AppViewController {
  func bulbToastView(title: String) -> ToastView {
    let toastView = ToastView(
      tipPosition: .none,
      text: title,
      icon: .bulbWhite
    )
    
    toastView.setConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(64)
    }
    
    return toastView
  }
}
