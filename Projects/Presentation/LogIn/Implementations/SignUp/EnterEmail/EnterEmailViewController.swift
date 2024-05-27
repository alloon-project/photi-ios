//
//  EnterEmailViewController.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class EnterEmailViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let viewModel: EnterEmailViewModel
  
  // MARK: - UI Components
  private let navigationBar = PrimaryNavigationView(textType: .none, iconType: .one)
  private let progressBar = LargeProgressBar(step: .one)
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "환영합니다!\n이메일을 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    label.numberOfLines = 2
    
    return label
  }()
  
  // TODO: - emailTextField
  private let lineTextField = LineTextField(placeholder: "이메일", type: .helper)
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음")
  // TODO: - DS 적용 후 이미지 변경
  private let emailFormWarningView = CommentView(
    .warning, text: "이메일 형태가 올바르지 않아요", icon: UIImage(systemName: "xmark")!, isActivate: true
  )
  private let emailTextCountWarningView = CommentView(
    .warning, text: "100자 이하의 이메일을 사용해주세요", icon: UIImage(systemName: "xmark")!, isActivate: true
  )
  private let duplicateEmailWarningView = CommentView(
    .warning, text: "이미 가입된 이메일이예요", icon: UIImage(systemName: "xmark")!, isActivate: true
  )
  
  // MARK: - Initialziers
  init(viewModel: EnterEmailViewModel) {
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
private extension EnterEmailViewController {
  func setupUI() {
    view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, progressBar, titleLabel, lineTextField, nextButton)
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
    
    lineTextField.snp.makeConstraints {
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
private extension EnterEmailViewController {
  func bind() {
    let input = EnterEmailViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapLeftButton,
      didTapNextButton: nextButton.rx.tap,
      userEmail: lineTextField.rx.text,
      endEditingUserEmail: lineTextField.textField.rx.controlEvent(.editingDidEnd),
      editingUserEmail: lineTextField.textField.rx.controlEvent(.editingChanged)
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: EnterEmailViewModel.Output) {
    output.isValidEmailForm
      .emit(with: self) { owner, isValid in
        if isValid {
          owner.convertLineTextField(commentView: nil)
        } else {
          owner.convertLineTextField(commentView: owner.emailFormWarningView)
        }
      }
      .disposed(by: disposeBag)
    
    output.isOverMaximumText
      .emit(with: self) { owner, isOver in
        if isOver {
          owner.convertLineTextField(commentView: owner.emailTextCountWarningView)
        } else {
          owner.convertLineTextField(commentView: nil)
        }
      }
      .disposed(by: disposeBag)
    
    output.isEnabledNextButton
      .emit(to: nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Methods
private extension EnterEmailViewController {
  func convertLineTextField(commentView: CommentView?) {
    if let commentView = commentView {
      lineTextField.commentViews = [commentView]
      lineTextField.mode = .error
    } else {
      lineTextField.commentViews = []
      lineTextField.mode = .success
    }
  }
}
