//
//  ChallengeModifyViewController.swift
//  Presentation
//
//  Created by 임우섭 on 5/17/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import Kingfisher
import SnapKit
import CoreUI
import DesignSystem

final class ChallengeModifyViewController: UIViewController, ViewControllerable {
  enum Constants {
    static let navigationHeight: CGFloat = 56
  }
  
  // MARK: - Properties
  private let viewModel: ChallengeModifyViewModel
  private var cancellables = Set<AnyCancellable>()
  private var hashTags = [String]() {
    didSet { hashTagCollectionView.reloadData() }
  }
  private let didTapChallengeNameSubject = PassthroughSubject<Void, Never>()
  private let didTapChallengeHashtagSubject = PassthroughSubject<Void, Never>()
  private let didTapChallengeGoalSubject = PassthroughSubject<Void, Never>()
  private let didTapChallengeCoverSubject = PassthroughSubject<Void, Never>()
  private let didTapChallengeRuleSubject = PassthroughSubject<Void, Never>()
  private let didTapConfirmButtonAtAlertSubject = PassthroughSubject<Void, Never>()

  private let titleTextSubject = PassthroughSubject<String, Never>()
  private let hashtagsSubject = PassthroughSubject<[String], Never>()
  private let proveTimeSubject = PassthroughSubject<String, Never>()
  private let goalSubject = PassthroughSubject<String, Never>()
  private let imageSubject = PassthroughSubject<UIImageWrapper, Never>()
  private let rulesSubject = PassthroughSubject<[String], Never>()
  private let endDateSubject = PassthroughSubject<String, Never>()
  
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
  
  func render(with model: ModifyPresentationModel) {
    renderLeftSection(model)
    renderRightSection(model)
    renderThumbnail(from: model.imageUrlString)
  }
  
  func renderLeftSection(_ model: ModifyPresentationModel) {
    configureTitleLabel(model.title)
    hashTags = model.hashtags
    verificationTimeView.verificationTime = model.verificationTime
    goalView.goal = model.goal
  }
  
  func renderRightSection(_ model: ModifyPresentationModel) {
    ruleView.rules = model.rules
    deadLineView.deadLine = model.deadLine
  }
  
  func renderThumbnail(from urlString: String) {
    guard let url = URL(string: urlString) else { return }

    thumbnailImageView.kf.setImage(
      with: url,
      options: [.callbackQueue(.mainCurrentOrAsync)]
    ) { [weak self] result in
      guard let self else { return }
      switch result {
        case .success(let imageResult):
          self.imageSubject.send(UIImageWrapper(image: imageResult.image))
        case .failure:
          self.imageSubject.send(UIImageWrapper(image: .challengeOrganizeLuckyday))
      }
    }
  }
}

// MARK: - Bind Methods
private extension ChallengeModifyViewController {
  func bind() {
    let input = ChallengeModifyViewModel.Input(
      didTapBackButton: navigationBar.didTapBackButton,
      didTapChallengeName: didTapChallengeNameSubject.eraseToAnyPublisher(),
      didTapChallengeHashtag: didTapChallengeHashtagSubject.eraseToAnyPublisher(),
      didTapChallengeGoal: didTapChallengeGoalSubject.eraseToAnyPublisher(),
      didTapChallengeCover: didTapChallengeCoverSubject.eraseToAnyPublisher(),
      didTapChallengeRule: didTapChallengeRuleSubject.eraseToAnyPublisher(),
      didTapModifyButton: modifyButton.tapPublisher,
      didTapConfirmButtonAtAlert: didTapConfirmButtonAtAlertSubject.eraseToAnyPublisher(),
      titleText: titleTextSubject.eraseToAnyPublisher(),
      hashtags: hashtagsSubject.eraseToAnyPublisher(),
      proveTime: proveTimeSubject.eraseToAnyPublisher(),
      goal: goalSubject.eraseToAnyPublisher(),
      image: imageSubject.eraseToAnyPublisher(),
      rules: rulesSubject.eraseToAnyPublisher(),
      endDate: endDateSubject.eraseToAnyPublisher()
    )

    let output = viewModel.transform(input: input)

    viewBind()
    bind(for: output)
  }
  
  func viewBind() {
    ruleView.didTapViewAllRulesButton
      .sinkOnMain(with: self) { owner, rules in
        owner.displayRuleDetailViewController(rules)
      }.store(in: &cancellables)

    setupTapGestures()
  }

  func setupTapGestures() {
    let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTitle))
    challengeTitleLabel.isUserInteractionEnabled = true
    challengeTitleLabel.addGestureRecognizer(titleTapGesture)

    let hashTagTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHashtag))
    hashTagCollectionView.addGestureRecognizer(hashTagTapGesture)

    let goalTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapGoal))
    goalView.addGestureRecognizer(goalTapGesture)

    let verificationTimeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapGoal))
    verificationTimeView.addGestureRecognizer(verificationTimeTapGesture)

    let deadLineTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapGoal))
    deadLineView.addGestureRecognizer(deadLineTapGesture)

    let thumbnailTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCover))
    thumbnailImageView.isUserInteractionEnabled = true
    thumbnailImageView.addGestureRecognizer(thumbnailTapGesture)

    let ruleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapRule))
    ruleView.addGestureRecognizer(ruleTapGesture)
  }

  @objc func didTapTitle() {
    didTapChallengeNameSubject.send(())
  }

  @objc func didTapHashtag() {
    didTapChallengeHashtagSubject.send(())
  }

  @objc func didTapGoal() {
    didTapChallengeGoalSubject.send(())
  }

  @objc func didTapCover() {
    didTapChallengeCoverSubject.send(())
  }

  @objc func didTapRule() {
    didTapChallengeRuleSubject.send(())
  }
  
  func bind(for output: ChallengeModifyViewModel.Output) {
    output.presentationModel
      .sinkOnMain(with: self) { owner, model in
        owner.render(with: model)
      }.store(in: &cancellables)

    output.notChallengeMember
      .sinkOnMain(with: self) { owner, message in
        owner.presentAlertWaring(message: message)
      }.store(in: &cancellables)

    output.fileTooLargeError
      .sinkOnMain(with: self) { owner, message in
        owner.presentAlertWaring(message: message)
      }.store(in: &cancellables)

    output.imageTypeError
      .sinkOnMain(with: self) { owner, message in
        owner.presentAlertWaring(message: message)
      }.store(in: &cancellables)

    output.notPartyManager
      .sinkOnMain(with: self) { owner, message in
        owner.presentAlertWaring(message: message)
      }.store(in: &cancellables)

    output.notExistChallenge
      .sinkOnMain(with: self) { owner, message in
        owner.presentAlertWaring(message: message)
      }.store(in: &cancellables)

    output.networkUnstable
      .sinkOnMain(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }.store(in: &cancellables)
  }
}

// MARK: - ChallengeModifyPresentable
extension ChallengeModifyViewController: ChallengeModifyPresentable {
  func modifyName(name: String) {
    configureTitleLabel(name)
    titleTextSubject.send(name)
  }

  func modifyGoal(goal: String, verificationTime: String, endDate: String) {
    goalView.goal = goal
    verificationTimeView.verificationTime = verificationTime
    deadLineView.deadLine = endDate

    goalSubject.send(goal)
    proveTimeSubject.send(verificationTime)
    endDateSubject.send(endDate)
  }

  func modifyCover(image: UIImageWrapper) {
    thumbnailImageView.image = image.image
    imageSubject.send(image)
  }

  func modifyHashtags(hashtags: [String]) {
    self.hashTags = hashtags
    hashtagsSubject.send(hashtags)
  }

  func modifyRules(rules: [String]) {
    ruleView.rules = rules
    rulesSubject.send(rules)
  }

  func presentAlertWaring(message: String) {
    let alert = AlertViewController(alertType: .confirm, title: message)
    alert.didTapConfirmButton
      .sinkOnMain(with: self) { owner, _ in
        owner.didTapConfirmButtonAtAlertSubject.send(())
      }.store(in: &cancellables)
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
