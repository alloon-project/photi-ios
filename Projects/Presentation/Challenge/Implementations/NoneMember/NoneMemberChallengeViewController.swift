//
//  NoneMemberChallengeViewController.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class NoneMemberChallengeViewController: UIViewController, ViewControllerable {
  enum Constants {
    static let navigationHeight: CGFloat = 56
  }
  
  // MARK: - Properties
  private let viewModel: NoneMemberChallengeViewModel
  private let disposeBag = DisposeBag()
  private var hashTags = [String]() {
    didSet { hashTagCollectionView.reloadData() }
  }
  private var invitationCodeViewController: InvitationCodeViewController?
  private var isUnlocked: Bool = false
  
  private let codeRelay = BehaviorRelay<String>(value: "")
  private let didFinishVerifyRelay = PublishRelay<Void>()
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  private let mainContainerView = UIView()
  private let leftView = UIView()
  private let rightView = UIView()
  private let challengeTitleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    
    return label
  }()
  private let hashTagCollectionView = HashTagCollectionView(allignMent: .leading)
  private let verificationTimeView = ChallengeVerificationTimeView()
  private let goalView = ChallengeGoalView()
  private let thumbnailView = ChallengeThumbnailView()
  private let ruleView = ChallengeRuleView()
  private let deadLineView = ChallengeDeadLineView()
  
  private let joinButton = FilledRoundButton(type: .primary, size: .xLarge, text: "함께하기")
  
  // MARK: - Initializers
  init(viewModel: NoneMemberChallengeViewModel) {
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
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideTabBar(animated: true)
  }
}

// MARK: - UI Methods
private extension NoneMemberChallengeViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, mainContainerView, joinButton)
    mainContainerView.addSubviews(leftView, rightView)
    leftView.addSubviews(
      challengeTitleLabel,
      hashTagCollectionView,
      verificationTimeView,
      goalView
    )
    
    rightView.addSubviews(thumbnailView, ruleView, deadLineView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(Constants.navigationHeight)
    }
    
    mainContainerView.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(13)
      $0.centerX.equalToSuperview()
    }
    
    leftView.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.top.bottom.equalTo(rightView)
      $0.width.equalTo(175)
    }
    
    rightView.snp.makeConstraints {
      $0.leading.equalTo(leftView.snp.trailing).offset(16)
      $0.trailing.top.bottom.equalToSuperview()
      $0.width.equalTo(136)
    }
    
    setLeftViewsConstraints()
    setRightViewsConstraints()
    
    joinButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(48)
    }
  }
  
  func setLeftViewsConstraints() {
    challengeTitleLabel.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }
    
    hashTagCollectionView.snp.makeConstraints {
      $0.top.equalTo(challengeTitleLabel.snp.bottom)
      $0.leading.trailing.equalTo(challengeTitleLabel)
      $0.height.equalTo(50)
    }

    verificationTimeView.snp.makeConstraints {
      $0.top.equalTo(hashTagCollectionView.snp.bottom).offset(18)
      $0.height.equalTo(71)
      $0.leading.trailing.equalToSuperview()
    }
    
    goalView.snp.makeConstraints {
      $0.top.equalTo(verificationTimeView.snp.bottom).offset(18)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  func setRightViewsConstraints() {
    thumbnailView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(194)
    }
    
    ruleView.snp.makeConstraints {
      $0.top.equalTo(thumbnailView.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(268)
    }
    
    deadLineView.snp.makeConstraints {
      $0.top.equalTo(ruleView.snp.bottom).offset(16)
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(71)
    }
  }
}

// MARK: - Bind Methods
private extension NoneMemberChallengeViewController {
  func bind() {
    let input = NoneMemberChallengeViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      didTapJoinButton: joinButton.rx.tap,
      invitationCode: codeRelay.asDriver(),
      didFinishVerify: didFinishVerifyRelay.asSignal()
    )
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() {
    ruleView.rx.didTapViewAllRulesButton
      .bind(with: self) { owner, rules in
        owner.displayRuleDetailViewController(rules)
      }
      .disposed(by: disposeBag)
  }
  
  func viewModelBind(for output: NoneMemberChallengeViewModel.Output) {
    output.isLockChallenge
      .drive(with: self) { owner, isLock in
        guard isLock else { return }
        owner.joinButton.icon = .lockClosedWhite
      }
      .disposed(by: disposeBag)
    
    output.displayUnlockView
      .emit(with: self) { owner, _ in
        owner.displayInvitationCodeViewController()
      }
      .disposed(by: disposeBag)
    
    output.verifyCodeResult
      .emit(with: self) { owner, result in
        guard let viewController = owner.invitationCodeViewController else { return }
        result ? viewController.convertToUnlock() : viewController.displayToastView()
        owner.isUnlocked = result
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - NoneMemberChallengePresentable
extension NoneMemberChallengeViewController: NoneMemberChallengePresentable { }

// MARK: - UICollectionViewDataSource
extension NoneMemberChallengeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hashTags.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(HashTagCell.self, for: indexPath)
    let text = hashTags[indexPath.row]
    cell.configure(type: .text(size: .medium, type: .gray), text: text)
    
    return cell
  }
}

// MARK: -
extension NoneMemberChallengeViewController: InvitationCodeViewControllerDelegate {
  func didTapUnlockButton(_ viewController: InvitationCodeViewController, code: String) {
    codeRelay.accept(code)
  }
  
  func didDismiss() {
    invitationCodeViewController = nil
    
    if isUnlocked { didFinishVerifyRelay.accept(()) }
  }
}

// MARK: - Private Methods
private extension NoneMemberChallengeViewController {
  func configureTitleLabel(_ title: String) {
    challengeTitleLabel.attributedText = title.attributedString(
      font: .heading2,
      color: .gray900
    )
  }
  
  func displayRuleDetailViewController(_ rules: [String]) {
    let viewController = RuleDetailViewController(rules: rules)
    viewController.modalPresentationStyle = .overFullScreen
    present(viewController, animated: false)
  }
  
  func displayInvitationCodeViewController() {
    guard invitationCodeViewController == nil else { return }
    let viewController = InvitationCodeViewController()
    viewController.modalPresentationStyle = .overFullScreen
    self.invitationCodeViewController = viewController
    viewController.delegate = self
    present(viewController, animated: false)
  }
}
