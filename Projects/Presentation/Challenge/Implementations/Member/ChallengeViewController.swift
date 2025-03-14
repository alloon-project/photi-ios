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

final class ChallengeViewController: UIViewController, ViewControllerable {
  enum Constants {
    static let navigationHeight: CGFloat = 56
    static let titleViewHeight: CGFloat = 300
    static let mainViewTopOffset: CGFloat = titleViewHeight - segmentControlHeight
    static let segmentControlHeight: CGFloat = 38
  }
  
  // MARK: - Properties
  private let viewModel: ChallengeViewModel
  private let disposeBag = DisposeBag()
  private var segmentIndex: Int = 0
  
  private let viewDidLoadRelay = PublishRelay<Void>()
  private let didTapConfirmButtonAtAlert = PublishRelay<Void>()
  private let didTapLoginButtonAtAlert = PublishRelay<Void>()
  
  // MARK: - UI Components
  private var segmentViewControllers = [UIViewController]()
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    rigthItems: [.shareButton, .optionButton],
    displayMode: .white
  )
  private let titleView = ChallengeTitleView()
  private let segmentControl = PhotiSegmentControl(items: ["피드", "소개", "파티원"])
  private let mainView = UIView()
  private let mainContentView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
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
    bind()
    viewDidLoadRelay.accept(())
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideTabBar(animated: true)
  }
}

// MARK: - UI Methods
private extension ChallengeViewController {
  func setupUI() {
    setViewHierarhcy()
    setConstraints()
  }
  
  func setViewHierarhcy() {
    view.addSubviews(titleView, navigationBar, mainView)
    mainView.addSubviews(segmentControl, mainContentView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(Constants.navigationHeight)
    }
    
    titleView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(Constants.titleViewHeight)
    }
    
    mainView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(Constants.mainViewTopOffset)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    segmentControl.snp.makeConstraints {
      $0.leading.trailing.top.equalToSuperview()
      $0.height.equalTo(Constants.segmentControlHeight)
    }
    
    mainContentView.snp.makeConstraints {
      $0.top.equalTo(segmentControl.snp.bottom)
      $0.bottom.trailing.leading.equalToSuperview()
    }
  }
}

// MARK: - Bind
private extension ChallengeViewController {
  func bind() {
    let input = ChallengeViewModel.Input(
      viewDidLoad: viewDidLoadRelay.asSignal(),
      didTapBackButton: navigationBar.rx.didTapBackButton.asSignal(),
      didTapConfirmButtonAtAlert: didTapConfirmButtonAtAlert.asSignal(),
      didTapLoginButtonAtAlert: didTapLoginButtonAtAlert.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
    viewBind()
  }
  
  func viewBind() {
    segmentControl.rx.selectedSegment
      .bind(with: self) { owner, index in
        owner.updateSegmentViewController(to: index)
      }
      .disposed(by: disposeBag)
  }
  
  func bind(for output: ChallengeViewModel.Output) {
    output.challengeInfo
      .drive(with: self) { owner, model in
        owner.titleView.configure(with: model)
      }
      .disposed(by: disposeBag)
    
    output.challengeNotFound
      .emit(with: self) { owner, _ in
        owner.presentChallengeNotFoundWaring()
      }
      .disposed(by: disposeBag)
    
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.presentNetworkWarning(reason: nil)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - ChallengePresentable
extension ChallengeViewController: ChallengePresentable {
  func attachViewControllerables(_ viewControllerables: ViewControllerable...) {
    segmentViewControllers = viewControllerables.map(\.uiviewController)
    
    attachViewController(segmentIndex: segmentIndex)
  }
  
  func didChangeContentOffsetAtMainContainer(_ offset: Double) {
    let minOffset = navigationBar.frame.maxY - 5
    let maxOffset = Constants.mainViewTopOffset
    
    let offset = offset.bound(lower: minOffset, upper: maxOffset)
    let mainContainerOffset = minOffset + maxOffset - offset
    
    mainView.snp.updateConstraints {
      $0.top.equalToSuperview().offset(mainContainerOffset)
    }
  }
  
  func presentChallengeNotFoundWaring() {
    let alert = AlertViewController(alertType: .confirm, title: "존재하지 않는 챌린지입니다.")
    alert.rx.didTapConfirmButton
      .bind(with: self) { owner, _ in
        owner.didTapConfirmButtonAtAlert.accept(())
      }
      .disposed(by: disposeBag)
    alert.present(to: self, animted: true)
  }
  
  func presentNetworkWarning(reason: String?) {
    presentNetworkUnstableAlert(reason: reason)
  }
  
  func presentLoginTrrigerWarning() {
    let alert = self.presentLoginTriggerAlert()
    
    alert.rx.didTapConfirmButton
      .bind(with: self) { owner, _ in
        owner.didTapLoginButtonAtAlert.accept(())
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Methods
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
