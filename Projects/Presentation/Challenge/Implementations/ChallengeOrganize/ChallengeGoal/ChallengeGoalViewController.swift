//
//  ChallengeGoalViewController.swift
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

final class ChallengeGoalViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: ChallengeGoalViewModel
  private var isPublicRelay: BehaviorRelay<Bool> = BehaviorRelay(value: true)
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let progressBar = LargeProgressBar(step: .one)
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "챌린지의 목표는 무엇인가요?".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let challengeGoalTextView = LineTextView(
    placeholder: "이루고자 하는 목표를 알려주세요!",
    type: .count(120)
  )

  private let setProveTimeLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "하루 인증 시간을 정해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let publicComment = CommentView(
    .condition,
    text: "다양한 사람들과 챌린지를 즐겨요",
    icon: .postitBlue,
    isActivate: true
  )
  
  private let privateComment = CommentView(
    .condition,
    text: "친한 친구들과 챌린지를 즐겨요",
    icon: .peopleBlue,
    isActivate: true
  )
  
  private let publicSwitch = {
    let publicSwitch = UISwitch()
    publicSwitch.isOn = true
    publicSwitch.onTintColor = .blue400
    publicSwitch.addTarget(self, action: #selector(toggleSwitch), for: .touchUpInside)
    
    return publicSwitch
  }()
  
  private let nextButton = FilledRoundButton(
    type: .primary,
    size: .xLarge,
    text: "다음"
  )
  
  // MARK: - Initialziers
  init(viewModel: ChallengeGoalViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cylces
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    bind()
  }
  
  // MARK: - UI Responder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension ChallengeGoalViewController {
  func setupUI() {
    view.backgroundColor = .white
    challengeGoalTextField.setKeyboardType(.emailAddress)
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      progressBar,
      titleLabel,
      challengeGoalTextField,
      publicLabel,
      publicComment,
      privateComment,
      publicSwitch,
      nextButton
    )
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    progressBar.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(progressBar.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    challengeGoalTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    publicLabel.snp.makeConstraints {
      $0.top.equalTo(challengeGoalTextField.snp.bottom).offset(53)
      $0.leading.equalTo(challengeGoalTextField)
    }
    
    publicComment.snp.makeConstraints {
      $0.leading.equalTo(publicLabel)
      $0.top.equalTo(publicLabel.snp.bottom).offset(16)
    }
    
    privateComment.snp.makeConstraints {
      $0.leading.equalTo(publicLabel)
      $0.top.equalTo(publicLabel.snp.bottom).offset(16)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension ChallengeGoalViewController {
  func bind() {
    let input = ChallengeGoalViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      challengeGoal: challengeGoalTextField.rx.text,
      isPublicChallenge: isPublicRelay.asObservable(),
      didTapNextButton: nextButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: ChallengeGoalViewModel.Output) { }
}

// MARK: - ChallengeGoalPresentable
extension ChallengeGoalViewController: ChallengeGoalPresentable { }

// MARK: - Private Methods
private extension ChallengeGoalViewController {
  @objc
  func toggleSwitch() {
    publicSwitch.isOn.toggle()
    isPublicRelay.accept(publicSwitch.isOn)
  }
}
