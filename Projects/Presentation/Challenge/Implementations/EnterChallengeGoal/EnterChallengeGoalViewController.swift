//
//  EnterChallengeGoalViewController.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import UIKit
import Coordinator
import SnapKit
import CoreUI
import DesignSystem

final class EnterChallengeGoalViewController: UIViewController, ViewControllerable {
  enum Constants {
    static let navigationBarHeight = 56
    static let mainTitleLabelText = "이 챌린지에서 이루고 싶은\n회원님만의 목표를 알려주세요"
    static let subTitleLabelText = "다른 파티원도 확인할 수 있어요"
  }
  
  // MARK: - Properties
  private let viewModel: EnterChallengeGoalViewModel
  private var cancellables = Set<AnyCancellable>()
  private let mode: ChallengeGoalMode
  private let challengeName: String

  private let didTapSkipButtonSubject = PassthroughSubject<Void, Never>()

  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  private let imageView = UIImageView(image: .challengeEditGoal)
  private let mainLabel: UILabel = {
    let label = UILabel()
    label.attributedText = Constants.mainTitleLabelText.attributedString(
      font: .heading4,
      color: .gray900
    )
    label.numberOfLines = 0
    return label
  }()
  private let subLabel: UILabel = {
    let label = UILabel()
    label.attributedText = Constants.subTitleLabelText.attributedString(
      font: .caption1,
      color: .gray700
    )
    return label
  }()
  
  private let textField = LineTextField(placeholder: "예) 잊지못할 추억 남기기", type: .count(16))
  
  private lazy var skipButton = FilledRoundButton(type: .quaternary, size: .xLarge, text: "건너뛰기")
  private let saveButton = FilledRoundButton(type: .primary, size: .xLarge, text: "내 목표 저장하기")
  
  // MARK: - Initializers
  init(
    mode: ChallengeGoalMode,
    challengeName: String,
    viewModel: EnterChallengeGoalViewModel
  ) {
    self.mode = mode
    self.challengeName = challengeName
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
  
  // MARK: - UI Responder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension EnterChallengeGoalViewController {
  func setupUI() {
    view.backgroundColor = .white
    navigationBar.title = challengeName
    
    setViewHierarchy()
    setConstraints()
    
    if case let .edit(goal) = mode {
      textField.text = goal
    } else {
      setupAddGoalUI()
    }
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      imageView,
      mainLabel,
      subLabel,
      textField,
      saveButton
    )
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(Constants.navigationBarHeight)
    }
    
    imageView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(24)
      $0.height.equalTo(126)
    }
    
    mainLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(imageView.snp.bottom).offset(24)
    }
    
    subLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(mainLabel.snp.bottom).offset(16)
    }
    
    textField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(subLabel.snp.bottom).offset(24)
    }
    
    saveButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(48)
    }
  }
  
  func setupAddGoalUI() {
    view.addSubview(skipButton)

    skipButton.snp.makeConstraints {
      $0.edges.equalTo(saveButton)
    }
  }
}

// MARK: - Bind Methods
private extension EnterChallengeGoalViewController {
  func bind() {
    let input = EnterChallengeGoalViewModel.Input(
      didTapBackButton: navigationBar.didTapBackButton,
      goalText: textField.textPublisher,
      didTapSaveButton: saveButton.tapPublisher,
      didTapSkipButton: didTapSkipButtonSubject.eraseToAnyPublisher()
    )

    let output = viewModel.transform(input: input)

    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() {
    if case .join = mode {
      addGoalModeViewBind()
    }
  }
  
  func addGoalModeViewBind() {
    textField.textPublisher
      .map { $0.isEmpty }
      .sinkOnMain(with: self) { owner, isEmpty in
        owner.skipButton.isHidden = !isEmpty
        owner.saveButton.isHidden = isEmpty
      }.store(in: &cancellables)

    skipButton.tapPublisher
      .sinkOnMain(with: self) { owner, _ in
        owner.didTapSkipButtonSubject.send(())
      }.store(in: &cancellables)
  }
  
  func viewModelBind(for output: EnterChallengeGoalViewModel.Output) {
    output.saveButtonIsEnabled
      .sinkOnMain(with: self) { owner, isEnabled in
        owner.saveButton.isEnabled = isEnabled
      }.store(in: &cancellables)

    output.networkUnstable
      .sinkOnMain(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }.store(in: &cancellables)

    output.alreadyJoined
      .sinkOnMain(with: self) { owner, _ in
        owner.displayAlreadyJoinPopUp()
      }.store(in: &cancellables)

    output.exceedMaximumChallenge
      .sinkOnMain(with: self) { owner, message in
        owner.presentExceedMaximumChallengeAlert(message: message)
      }.store(in: &cancellables)
  }
}

// MARK: - EditChallengeGoalPresentable
extension EnterChallengeGoalViewController: EnterChallengeGoalPresentable { }

// MARK: - Private Methods
private extension EnterChallengeGoalViewController {
  func displayAlreadyJoinPopUp() {
    let popUp = AlertViewController(alertType: .confirm, title: "이미 참여한 챌린지예요")
    popUp.present(to: self, animted: false)
  }
  
  func presentExceedMaximumChallengeAlert(message: String) {
    let alert = AlertViewController(
      alertType: .confirm,
      title: "챌린지 생성 실패",
      subTitle: message
    )
    alert.present(to: self, animted: true)
  }
}
