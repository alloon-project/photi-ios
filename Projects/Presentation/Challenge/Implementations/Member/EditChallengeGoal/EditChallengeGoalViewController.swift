//
//  EditChallengeGoalViewController.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class EditChallengeGoalViewController: UIViewController, ViewControllerable {
  enum Constants {
    static let navigationBarHeight = 56
    static let mainTitleLabelText = "이 챌린지에서 이루고 싶은\n회원님만의 목표를 알려주세요"
    static let subTitleLabelText = "다른 파티원도 확인할 수 있어요"
  }
  
  // MARK: - Properties
  private let viewModel: EditChallengeGoalViewModel
  private let disposeBag = DisposeBag()
  
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
  
  private let saveButton = FilledRoundButton(type: .primary, size: .xLarge, text: "내 목표 저장하기")
  
  // MARK: - Initializers
  init(viewModel: EditChallengeGoalViewModel) {
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
}

// MARK: - UI Methods
private extension EditChallengeGoalViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
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
}

// MARK: - Bind Methods
private extension EditChallengeGoalViewController {
  func bind() {
    let input = EditChallengeGoalViewModel.Input(
      goalText: textField.rx.text,
      didTapSaveButton: saveButton.rx.tap
    )
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() { }
  
  func viewModelBind(for output: EditChallengeGoalViewModel.Output) {
    output.saveButtonisEnabled
      .drive(saveButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }
}

// MARK: - EditChallengeGoalPresentable
extension EditChallengeGoalViewController: EditChallengeGoalPresentable { }
