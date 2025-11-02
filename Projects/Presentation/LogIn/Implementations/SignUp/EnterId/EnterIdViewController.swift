//
//  EnterIdViewController.swift
//  LogInImpl
//
//  Created by jung on 6/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Coordinator
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class EnterIdViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: EnterIdViewModel
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  private let progressBar = LargeProgressBar(step: .two)
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "아이디를 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "알파벳 소문자, 숫자, 특수문자(_)만 사용 가능해요".attributedString(
      font: .caption1,
      color: .gray700
    )
    
    return label
  }()
  
  private let idTextField = ButtonTextField(buttonText: "중복검사", placeholder: "아이디", type: .helper)
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음")

  private let idFormWarningView = CommentView(
    .warning, text: "알파벳 소문자, 숫자, 특수문자(_)만 사용 가능해요", icon: .closeRed, isActivate: true
  )
  private let duplicateIdWardningView = CommentView(
    .warning, text: "이미 사용중인 아이디예요", icon: .closeRed, isActivate: true
  )
  private let unAvailableIdWardningView = CommentView(
    .warning, text: "사용할 수 없는 아이디예요", icon: .closeRed, isActivate: true
  )

  private let validIdCommentView = CommentView(
    .condition, text: "사용할 수 있는 아이디예요", icon: .checkBlue, isActivate: true
  )
  
  // MARK: - Initializers
  init(viewModel: EnterIdViewModel) {
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
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.progressBar.step = .three
    }
  }
  
  // MARK: - UI Responder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension EnterIdViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    idTextField.textField.autocapitalizationType = .none
    nextButton.isEnabled = false
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      progressBar,
      titleLabel,
      subTitleLabel,
      idTextField,
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
    
    subTitleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.top.equalTo(titleLabel.snp.bottom).offset(16)
    }
    
    idTextField.snp.makeConstraints {
      $0.top.equalTo(subTitleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension EnterIdViewController {
  func bind() {
    let input = EnterIdViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      didTapNextButton: nextButton.rx.tap,
      didTapVerifyIdButton: idTextField.rx.didTapButton,
      userId: idTextField.textField.rx.text.orEmpty
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(for: output)
  }
  
  func viewBind() {
    let textFieldEditingBegin = idTextField.textField.rx.controlEvent(.editingChanged)
      .share()
    
    textFieldEditingBegin
      .map { _ in false }
      .bind(to: nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    textFieldEditingBegin
      .bind(with: self) { owner, _ in
        owner.idTextField.commentViews = []
        owner.idTextField.mode = .default
      }
      .disposed(by: disposeBag)
    
    idTextField.rx.didTapButton
      .bind(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
  }
  
  func bind(for output: EnterIdViewModel.Output) {
    output.isDuplicateButtonEnabled
      .emit(to: idTextField.button.rx.isEnabled)
      .disposed(by: disposeBag)
    
    output.inValidIdForm
      .emit(with: self) { owner, _ in
        owner.idTextField.commentViews = [owner.idFormWarningView]
        owner.idTextField.mode = .error
      }
      .disposed(by: disposeBag)
    
    output.duplicateId
      .emit(with: self) { owner, _ in
        owner.idTextField.commentViews = [owner.duplicateIdWardningView]
        owner.idTextField.mode = .error
      }
      .disposed(by: disposeBag)
    
    output.unAvailableId
      .emit(with: self) { owner, _ in
        owner.idTextField.commentViews = [owner.unAvailableIdWardningView]
        owner.idTextField.mode = .error
      }
      .disposed(by: disposeBag)
    
    output.validId
      .emit(with: self) { owner, _ in
        owner.idTextField.commentViews = [owner.validIdCommentView]
        owner.idTextField.mode = .success
        owner.nextButton.isEnabled = true
      }
      .disposed(by: disposeBag)
    
    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - EnterIdPresentable
extension EnterIdViewController: EnterIdPresentable { }
