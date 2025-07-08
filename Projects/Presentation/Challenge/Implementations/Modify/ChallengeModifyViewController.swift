//
//  ChallengeModifyViewController.swift
//  Presentation
//
//  Created by 임우섭 on 5/17/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ChallengeModifyViewController: UIViewController, ViewControllerable {
  enum Constants {
    static let navigationHeight: CGFloat = 56
  }
  
  // MARK: - Properties
  private let viewModel: ChallengeModifyViewModel
  private let disposeBag = DisposeBag()
  private var hashTags = [String]() {
    didSet { hashTagCollectionView.reloadData() }
  }
  private let didTapChallengeNameRelay = PublishRelay<Void>()
  private let didTapChallengeHashtagRelay = PublishRelay<Void>()
  private let didTapChallengeGoalRelay = PublishRelay<Void>()
  private let didTapChallengeCoverRelay = PublishRelay<Void>()
  private let didTapChallengeRuleRelay = PublishRelay<Void>()
  private let didTapConfirmButtonAtAlert = PublishRelay<Void>()
  
  private let titleTextRelay = BehaviorRelay<String?>(value: nil)
  private let hashtagsRelay = BehaviorRelay<[String]?>(value: nil)
  private let proveTimeRelay = BehaviorRelay<String?>(value: nil)
  private let goalRelay = BehaviorRelay<String?>(value: nil)
  private let imageRelay = BehaviorRelay<UIImageWrapper?>(value: nil)
  private let rulesRelay = BehaviorRelay<[String]?>(value: nil)
  private let endDateRelay = BehaviorRelay<String?>(value: nil)
  
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
  private let thumbnailImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 10
    imageView.clipsToBounds = true
    return imageView
  }()
  private let ruleView = ChallengeRuleView()
  private let deadLineView = ChallengeDeadLineView()
  
  private let modifyButton = FilledRoundButton(type: .secondary, size: .xLarge, text: "저장하기")
  
  // MARK: - Initializers
  init(viewModel: ChallengeModifyViewModel) {
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
    hashTagCollectionView.dataSource = self
    setupUI()
    bind()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideTabBar(animated: true)
    presentModifyGuideToastView()
  }
}

// MARK: - UI Methods
private extension ChallengeModifyViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, mainContainerView, modifyButton)
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
    
    modifyButton.snp.makeConstraints {
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
private extension ChallengeModifyViewController {
  func bind() {
    let input = ChallengeModifyViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      didTapChallengeName: didTapChallengeNameRelay.asSignal(),
      didTapChallengeHashtag: didTapChallengeHashtagRelay.asSignal(),
      didTapChallengeGoal: didTapChallengeGoalRelay.asSignal(),
      didTapChallengeCover: didTapChallengeCoverRelay.asSignal(),
      didTapChallengeRule: didTapChallengeRuleRelay.asSignal(),
      didTapModifyButton: modifyButton.rx.tap,
      didTapConfirmButtonAtAlert: didTapConfirmButtonAtAlert.asSignal(),
      titleText: titleTextRelay.asSignal(onErrorJustReturn: nil),
      hashtags: hashtagsRelay.asSignal(onErrorJustReturn: nil),
      proveTime: proveTimeRelay.asSignal(onErrorJustReturn: nil),
      goal: goalRelay.asSignal(onErrorJustReturn: nil),
      image: imageRelay.asSignal(onErrorJustReturn: nil),
      rules: rulesRelay.asSignal(onErrorJustReturn: nil),
      endDate: endDateRelay.asSignal(onErrorJustReturn: nil)
    )
    
    let output = viewModel.transform(input: input)
    
    viewBind()
    
    bind(for: output)
  }
  
  func viewBind() {
    ruleView.rx.didTapViewAllRulesButton
      .bind(with: self) { owner, rules in
        owner.displayRuleDetailViewController(rules)
      }
      .disposed(by: disposeBag)
    
    challengeTitleLabel.rx.tapGesture()
      .when(.recognized)
      .bind(with: self) { owner, _ in
        owner.didTapChallengeNameRelay.accept(())
      }.disposed(by: disposeBag)
    
    hashTagCollectionView.rx.tapGesture()
      .when(.recognized)
      .bind(with: self) { owner, _ in
        owner.didTapChallengeHashtagRelay.accept(())
      }.disposed(by: disposeBag)
    
    goalView.rx.tapGesture()
      .when(.recognized)
      .bind(with: self) { owner, _ in
        owner.didTapChallengeGoalRelay.accept(())
      }.disposed(by: disposeBag)
    
    verificationTimeView.rx.tapGesture()
      .when(.recognized)
      .bind(with: self) { owner, _ in
        owner.didTapChallengeGoalRelay.accept(())
      }.disposed(by: disposeBag)
    
    deadLineView.rx.tapGesture()
      .when(.recognized)
      .bind(with: self) { owner, _ in
        owner.didTapChallengeGoalRelay.accept(())
      }.disposed(by: disposeBag)
    
    thumbnailImageView.rx.tapGesture()
      .when(.recognized)
      .bind(with: self) { owner, _ in
        owner.didTapChallengeCoverRelay.accept(())
      }.disposed(by: disposeBag)
    
    ruleView.rx.tapGesture()
      .when(.recognized)
      .bind(with: self) { owner, _ in
        owner.didTapChallengeRuleRelay.accept(())
      }.disposed(by: disposeBag)
  }
  
  func bind(for output: ChallengeModifyViewModel.Output) {
    output.notChallengeMember
      .emit(with: self) { owner, message in
        owner.presentAlertWaring(message: message)
      }.disposed(by: disposeBag)
    
    output.fileTooLargeError
      .emit(with: self) { owner, message in
        owner.presentAlertWaring(message: message)
      }.disposed(by: disposeBag)
    
    output.imageTypeError
      .emit(with: self) { owner, message in
        owner.presentAlertWaring(message: message)
      }.disposed(by: disposeBag)
    
    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - NoneMemberChallengePresentable
extension ChallengeModifyViewController: ChallengeModifyPresentable {
  func setLeftView(
     title: String,
     hashtags: [String],
     verificationTime: String,
     goal: String
   ) {
     configureTitleLabel(title)
     hashTags = hashtags
     verificationTimeView.verificationTime = verificationTime
     goalView.goal = goal
     
     titleTextRelay.accept(title)
     hashtagsRelay.accept(hashtags)
     proveTimeRelay.accept(verificationTime)
     goalRelay.accept(goal)
   }
   
   func setRightView(
     imageURLString: String,
     rules: [String],
     deadLine: String
   ) {
     if let url = URL(string: imageURLString) {
       thumbnailImageView.kf.setImage(
        with: url,
        options: [.callbackQueue(.mainCurrentOrAsync)]
       ) { [weak self] result in
         guard let self else { return }
         switch result {
         case .success(let imageResult):
           self.imageRelay.accept(UIImageWrapper(image: imageResult.image))
         case .failure(let isFail):
           print(isFail.localizedDescription)
           self.imageRelay.accept(UIImageWrapper(image: .challengeOrganizeLuckyday))
         }
       }
     }
     ruleView.rules = rules
     deadLineView.deadLine = deadLine
     
     rulesRelay.accept(rules)
     endDateRelay.accept(deadLine)
   }
  
  func modifyName(name: String) {
    configureTitleLabel(name)
    titleTextRelay.accept(name)
  }
  
  func modifyGoal(goal: String, verificationTime: String, endDate: String) {
    goalView.goal = goal
    verificationTimeView.verificationTime = verificationTime
    deadLineView.deadLine = endDate
    
    goalRelay.accept(goal)
    proveTimeRelay.accept(verificationTime)
    endDateRelay.accept(endDate)
  }
  
  func modifyCover(image: UIImageWrapper) {
    thumbnailImageView.image = image.image
    imageRelay.accept(image)
  }
  
  func modifyHashtags(hashtags: [String]) {
    self.hashTags = hashtags
    hashtagsRelay.accept(hashtags)
  }
  
  func modifyRules(rules: [String]) {
    ruleView.rules = rules
    rulesRelay.accept(rules)
  }
  
  func presentAlertWaring(message: String) {
    let alert = AlertViewController(alertType: .confirm, title: message)
    alert.rx.didTapConfirmButton
      .bind(with: self) { owner, _ in
        owner.didTapConfirmButtonAtAlert.accept(())
      }
      .disposed(by: disposeBag)
    alert.present(to: self, animted: true)
  }
  
  func presentModifyGuideToastView() {
    let toastText = "수정할 파트를 선택해 주세요~"
    let toastView = ToastView(tipPosition: .centerTop, text: toastText, icon: .bulbWhite)
    toastView.setConstraints {
      $0.bottom.equalToSuperview().inset(64)
      $0.centerX.equalToSuperview()
    }
    
    toastView.present(to: self)
  }
}

// MARK: - UICollectionViewDataSource
extension ChallengeModifyViewController: UICollectionViewDataSource {
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
private extension ChallengeModifyViewController {
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
}
