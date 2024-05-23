//
//  FindIdViewController.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import DesignSystem

final class FindIdViewController: UIViewController {
  private lazy var input = FindIdViewModel.Input(
    email: emailTextField.rx.text,
    didTapNextButton: nextButton.rx.tap
  )
  
  // MARK: - UI Components
  private let navigationBar = PrimaryNavigationView(textType: .center, iconType: .one, titleText: "아이디 찾기")
  private let announceLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.textAlignment = .left
    label.attributedText = "가입 시 사용했던 \n이메일을 입력해주세요".attributedString(font: .heading4, color: .gray900)
    return label
  }()
  
  private let emailTextField: LineTextField = {
    let textField = LineTextField(placeholder: "이메일", type: .helper)
    textField.commentViews = [.init(.warning, text: "이메일 형태가 올바르지 않아요", icon: UIImage(systemName: "xmark")!)]
    textField.setKeyboardType(.emailAddress)
    return textField
  }()
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음")
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  // MARK: - UIResponder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension FindIdViewController {
  func setupUI() {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .white
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, announceLabel, emailTextField, nextButton)
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
    
    emailTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(announceLabel.snp.bottom).offset(20)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}
