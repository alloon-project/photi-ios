//
//  EnterIdViewController.swift
//  LogInImpl
//
//  Created by jung on 6/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class EnterIdViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let viewModel: EnterIdViewModel
  
  // MARK: - UI Components
  private let navigationBar = PrimaryNavigationView(textType: .none, iconType: .one)
  private let progressBar = LargeProgressBar(step: .three)
  
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
    label.attributedText = "알파벳 소문자, 숫자, 특수문자만 사용 가능해요".attributedString(
      font: .caption1,
      color: .gray700
    )
    
    return label
  }()
  
  private let idTextField = ButtonTextField(buttonText: "중복검사", placeholder: "아이디", type: .default)
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음")
  
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
  }
}

// MARK: - UI Methods
private extension EnterIdViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, progressBar, titleLabel, subTitleLabel, idTextField, nextButton)
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
