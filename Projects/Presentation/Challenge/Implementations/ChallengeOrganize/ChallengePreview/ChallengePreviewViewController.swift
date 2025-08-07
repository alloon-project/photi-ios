//
//  ChallengePreviewViewController.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ChallengePreviewViewController: UIViewController, ViewControllerable {
  enum Constants {
    static let navigationHeight: CGFloat = 56
  }
  
  // MARK: - Properties
  private let viewModel: ChallengePreviewViewModel
  private let disposeBag = DisposeBag()
  private var hashTags = [String]() {
    didSet { hashTagCollectionView.reloadData() }
  }
  private var invitationCodeViewController: InvitationCodeViewController?
    
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  private let scrollView = UIScrollView()
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
  private let thumbnailImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 10
    imageView.clipsToBounds = true
    return imageView
  }()
  private let ruleView = ChallengeRuleView()
  private let deadLineView = ChallengeDeadLineView()
  
  private let organizeButton = FilledRoundButton(type: .primary, size: .xLarge, text: "챌린지 완성!")
  
  // MARK: - Initializers
  init(viewModel: ChallengePreviewViewModel) {
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
    view.backgroundColor = .white
    scrollView.showsVerticalScrollIndicator = false
    hashTagCollectionView.dataSource = self
    setupUI()
    bind()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentPreviewToastView()
  }
}

// MARK: - UI Methods
private extension ChallengePreviewViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, scrollView, organizeButton)
    scrollView.addSubview(mainContainerView)
    mainContainerView.addSubviews(leftView, rightView)
    leftView.addSubviews(
      challengeTitleLabel,
      hashTagCollectionView,
      verificationTimeView,
      goalView
    )
    
    rightView.addSubviews(thumbnailImageView, ruleView, deadLineView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(Constants.navigationHeight)
    }
    
    organizeButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(48)
    }
    
    scrollView.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom)
      $0.leading.trailing.equalToSuperview().inset(20)
      $0.bottom.equalTo(organizeButton.snp.top)
    }
    
    mainContainerView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.width.equalToSuperview()
    }
    
    leftView.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.top.bottom.equalTo(rightView)
      $0.width.equalTo(175)
    }
    
    rightView.snp.makeConstraints {
      $0.leading.equalTo(leftView.snp.trailing).offset(16)
      $0.height.equalTo(565)
      $0.trailing.top.equalToSuperview()
      $0.bottom.equalToSuperview().inset(16)
      $0.width.equalTo(136)
    }
    
    setLeftViewsConstraints()
    setRightViewsConstraints()
  }
  
  func setLeftViewsConstraints() {
    challengeTitleLabel.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(30)
    }
    
    hashTagCollectionView.snp.makeConstraints {
      $0.top.equalTo(challengeTitleLabel.snp.bottom)
      $0.leading.trailing.equalTo(challengeTitleLabel)
      $0.height.equalTo(50)
    }

    verificationTimeView.snp.makeConstraints {
      $0.top.equalTo(hashTagCollectionView.snp.bottom).offset(43)
      $0.height.equalTo(71)
      $0.leading.trailing.equalToSuperview()
    }
    
    goalView.snp.makeConstraints {
      $0.top.equalTo(verificationTimeView.snp.bottom).offset(18)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  func setRightViewsConstraints() {
    thumbnailImageView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(194)
    }
    
    ruleView.snp.makeConstraints {
      $0.top.equalTo(thumbnailImageView.snp.bottom).offset(16)
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
private extension ChallengePreviewViewController {
  func bind() {
    let input = ChallengePreviewViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      didTapOrganizeButton: organizeButton.rx.tap
    )
    let output = viewModel.transform(input: input)
    bind(for: output)
    viewBind()
  }
  
  func viewBind() {
    ruleView.rx.didTapViewAllRulesButton
      .bind(with: self) { owner, rules in
        owner.displayRuleDetailViewController(rules)
      }
      .disposed(by: disposeBag)
  }
  
  func bind(for output: ChallengePreviewViewModel.Output) {
    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
    
    output.emptyFileError
      .emit(with: self) { owner, message in
        owner.presentEmptyImageAlert(message: message)
      }
      .disposed(by: disposeBag)
    
    output.isLoading
      .emit { $0 ? LoadingAnimation.logo.start() : LoadingAnimation.logo.stop() }
      .disposed(by: disposeBag)
  }
}

// MARK: - ChallengePreviewPresentable
extension ChallengePreviewViewController: ChallengePreviewPresentable {
  func setLeftView(
    title: String,
    hashtags: [String],
    verificationTime: String,
    goal: String
  ) {
    configureTitleLabel(title)
    self.hashTags = hashtags
    verificationTimeView.verificationTime = verificationTime
    goalView.goal = goal
  }
  
  func setRightView(
    image: UIImageWrapper,
    rules: [String],
    deadLine: String
  ) {
    thumbnailImageView.image = image.image
    ruleView.rules = rules
    deadLineView.deadLine = deadLine
  }
}

// MARK: - UICollectionViewDataSource
extension ChallengePreviewViewController: UICollectionViewDataSource {
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

// MARK: - Private Methods
private extension ChallengePreviewViewController {
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
  
  func presentPreviewToastView() {
    let toastText = "완성된 챌린지를 확인해볼까요? 찰칵~"
    let toastView = ToastView(tipPosition: .leftTop, text: toastText, icon: .bulbWhite)
    toastView.setConstraints { [weak self] in
      guard let self else { return }
      $0.top.equalTo(self.hashTagCollectionView.snp.bottom)
      $0.centerX.equalToSuperview()
    }
    
    toastView.present(to: self)
  }
  
  func presentEmptyImageAlert(message: String) {
    let alert = AlertViewController(
      alertType: .confirm,
      title: "이미지를 찾을 수 없습니다.",
      subTitle: message
    )
    alert.present(to: self, animted: true)
  }
}
