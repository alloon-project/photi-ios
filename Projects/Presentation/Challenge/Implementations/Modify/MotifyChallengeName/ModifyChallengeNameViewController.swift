//
//  ModifyChallengeNameViewController.swift
//  Presentation
//
//  Created by 임우섭 on 5/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ModifyChallengeNameViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: ModifyChallengeNameViewModel
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    title: "챌린지 이름 수정",
    displayMode: .dark
  )
    
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "챌린지 이름을 정해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let modifyChallengeNameTextField: LineTextField = LineTextField(
    placeholder: "이 챌린지의 이름은?",
    type: .count(16)
  )

  private let nextButton = FilledRoundButton(
    type: .primary,
    size: .xLarge,
    text: "다음"
  )
  
  // MARK: - Initialziers
  init(viewModel: ModifyChallengeNameViewModel) {
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
private extension ModifyChallengeNameViewController {
  func setupUI() {
    view.backgroundColor = .white
    modifyChallengeNameTextField.setKeyboardType(.default)
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      titleLabel,
      modifyChallengeNameTextField,
      nextButton
    ) 
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    modifyChallengeNameTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension ModifyChallengeNameViewController {
  func bind() {
    let input = ModifyChallengeNameViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      modifyChallengeName: modifyChallengeNameTextField.rx.text,
      didTapNextButton: nextButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
    viewBind()
  }
  
  func bind(for output: ModifyChallengeNameViewModel.Output) { }
  
  func viewBind() {
    modifyChallengeNameTextField.rx.text
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .map { !$0.isEmpty }
      .bind(to: nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }
}

// MARK: - ModifyChallengeNamePresentable
extension ModifyChallengeNameViewController: ModifyChallengeNamePresentable { }
