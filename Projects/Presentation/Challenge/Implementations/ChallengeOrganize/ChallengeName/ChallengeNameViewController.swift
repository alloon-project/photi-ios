//
//  ChallengeNameViewController.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ChallengeNameViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: ChallengeNameViewModel
  private var isPublicRelay: BehaviorRelay<Bool> = BehaviorRelay(value: true)
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let progressBar = LargeProgressBar(step: .one)
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "챌린지 이름을 정해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let challengeNameTextField: LineTextField = LineTextField(
    placeholder: "이 챌린지의 이름은?",
    type: .count(16)
  )

  private let publicLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "전체공개".attributedString(
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
  init(viewModel: ChallengeNameViewModel) {
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
private extension ChallengeNameViewController {
  func setupUI() {
    view.backgroundColor = .white
    challengeNameTextField.setKeyboardType(.emailAddress)
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      progressBar,
      titleLabel,
      challengeNameTextField,
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
    
    challengeNameTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    publicLabel.snp.makeConstraints {
      $0.top.equalTo(challengeNameTextField.snp.bottom).offset(53)
      $0.leading.equalTo(challengeNameTextField)
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
private extension ChallengeNameViewController {
  func bind() {
    let input = ChallengeNameViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      challengeName: challengeNameTextField.rx.text,
      isPublicChallenge: isPublicRelay.asObservable(),
      didTapNextButton: nextButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: ChallengeNameViewModel.Output) { }
}

// MARK: - ChallengeNamePresentable
extension ChallengeNameViewController: ChallengeNamePresentable { }

// MARK: - Private Methods
private extension ChallengeNameViewController {
  @objc
  func toggleSwitch() {
    publicSwitch.isOn.toggle()
    isPublicRelay.accept(publicSwitch.isOn)
  }
}
