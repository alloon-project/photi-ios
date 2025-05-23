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
  private var memberCount: Int = 0
  private let dropDownData = ["챌린지 신고하기", "챌린지 탈퇴하기"]
  
  private let viewDidLoadRelay = PublishRelay<Void>()
  private let didTapConfirmButtonAtAlert = PublishRelay<Void>()
  private let didTapReportButton = PublishRelay<Void>()
  private let didTapLeaveButton = PublishRelay<Void>()
  
  // MARK: - UI Components
  private var segmentViewControllers = [UIViewController]()
  private let navigationOptionButton = PhotiNavigationButton.optionButton
  private lazy var navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    rigthItems: [.shareButton, navigationOptionButton],
    displayMode: .white
  )
  private let titleView = ChallengeTitleView()
  private let segmentControl = PhotiSegmentControl(items: ["피드", "소개", "파티원"])
  private lazy var dropDownView = DropDownView(anchorView: navigationOptionButton)
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
    dropDownView.dataSource = dropDownData
    dropDownView.delegate = self
    viewDidLoadRelay.accept(())
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideTabBar(animated: true)
  }
  
  // MARK: - UI Responder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension ChallengeViewController {
  func setupUI() {
    setViewHierarhcy()
    setConstraints()
  }
  
  func setViewHierarhcy() {
    view.addSubviews(titleView, navigationBar, mainView, dropDownView)
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
    
    dropDownView.setConstraints { [weak self] make in
      guard let self else { return }
      make.trailing.equalToSuperview().inset(24)
      make.top.equalTo(view.safeAreaLayoutGuide).offset(44)
      make.width.equalTo(130)
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
      didTapLeaveButton: didTapLeaveButton.asSignal(),
      didTapReportButton: didTapReportButton.asSignal()
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
    
    output.memberCount
      .drive(rx.memberCount)
      .disposed(by: disposeBag)
    
    output.challengeNotFound
      .emit(with: self) { owner, _ in
        owner.presentChallengeNotFoundWaring()
      }
      .disposed(by: disposeBag)
    
    output.networnUnstable
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
    
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: [.beginFromCurrentState, .curveEaseOut]
    ) {
      self.view.layoutIfNeeded()
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
}

// MARK: - DropDownDelegate
extension ChallengeViewController: DropDownDelegate {
  func dropDown(_ dropDown: DropDownView, didSelectRowAt: Int) {
    if didSelectRowAt == 0 {
      didTapReportButton.accept(())
    } else {
      presentLeaveChallengeAlert(memberCount: memberCount)
    }
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
  
  func presentLeaveChallengeAlert(memberCount: Int) {
    let alert = AlertViewController(
      alertType: .canCancel,
      title: "챌린지를 탈퇴할까요?",
      attributedSubTitle: leaveChallengeString(memberCount: memberCount)
    )
    alert.confirmButtonTitle = "탈퇴할게요"
    alert.cancelButtonTitle = "취소할게요"
    
    alert.rx.didTapConfirmButton
      .bind(to: didTapLeaveButton)
      .disposed(by: disposeBag)
    
    alert.present(to: self, animted: true)
  }
  
  func leaveChallengeString(memberCount: Int) -> NSAttributedString {
    if memberCount == 1 {
      return "회원님은 이 챌린지의 마지막 파티원예요.\n지금 탈퇴하면 챌린지가 삭제돼요.\n삭제된 챌린지는 복구할 수 없어요.\n정말 탈퇴하시겠어요?".attributedString(
        font: .body2,
        color: .gray600,
        alignment: .center
      )
      .setColor(.red400, for: "챌린지가 삭제돼요.")
      .setColor(.red400, for: "삭제된 챌린지는 복구할 수 없어요.")
    } else {
      return "탈퇴해도 기록은 남아있어요.\n탈퇴하시기 전에 직접 지워주세요.".attributedString(
        font: .body2,
        color: .gray600,
        alignment: .center
      )
    }
  }
}
