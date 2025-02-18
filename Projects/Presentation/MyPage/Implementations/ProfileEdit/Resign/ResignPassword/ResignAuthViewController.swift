//
//  ResignAuthViewController.swift
//  Presentation
//
//  Created by 임우섭 on 2/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import SnapKit
import Core
import DesignSystem

final class ResignAuthViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: ResignAuthViewModel

  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    title: "",
    displayMode: .dark
  )
  
  private let announceLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 1
    label.textAlignment = .left
    label.attributedText = "기존 비밀번호를 입력해주세요".attributedString(font: .heading4, color: .gray900)
    return label
  }()
  
  private let passwordTextField: PasswordTextField = {
    let textField = PasswordTextField(type: .default, mode: .default)
    textField.setKeyboardType(.default)
    return textField
  }()
  
  private let resignButton = FilledRoundButton(type: .primary, size: .xLarge, text: "탈퇴하기", mode: .disabled)
  
  private let alertVC = AlertViewController(
    alertType: .confirm,
    title: "비밀번호가 일치하지 않아요",
    subTitle: "다시 입력해주세요"
  )
  
  // MARK: - Initiazliers
  init(viewModel: ResignAuthViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    bind()
  }
  // MARK: - UIResponder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension ResignAuthViewController {
  func setupUI() {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .white
    self.resignButton.isEnabled = false
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, announceLabel, passwordTextField, resignButton)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    announceLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.top.equalTo(navigationBar.snp.bottom).offset(40)
    }
    
    passwordTextField.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(announceLabel.snp.bottom).offset(20)
    }
    
    resignButton.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Method
private extension ResignAuthViewController {
  func bind() {
    let input = ResignAuthViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      password: passwordTextField.rx.text,
      endEditingUserPassword: passwordTextField.textField.rx.controlEvent(.editingDidEnd),
      editingUserPassword: passwordTextField.textField.rx.controlEvent(.editingChanged),
      didTapNextButton: resignButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.presentWarningPopup()
      }
      .disposed(by: disposeBag)
    
    output.isPasswordEntered
      .emit(with: self) { owner, isEntered in
        owner.resignButton.isEnabled = isEntered
      }.disposed(by: disposeBag)
  }
}

// MARK: - ResignAuthPresentable
extension ResignAuthViewController: ResignAuthPresentable { }
