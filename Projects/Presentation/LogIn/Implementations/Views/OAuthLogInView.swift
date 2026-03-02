//
//  OAuthLogInView.swift
//  LogInImpl
//
//  Created by jung on 2/16/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

import UIKit
import Combine
import CoreUI
import DesignSystem

final class OAuthLogInView: UIView {
  var didTapAppleLoginButton: AnyPublisher<Void, Never> { appleLoginButton.tapPublisher }
  var didTapKakaoLoginButton: AnyPublisher<Void, Never> { kakaoLoginButton.tapPublisher }
  var didTapGoogleLoginButton: AnyPublisher<Void, Never> { googleLoginButton.tapPublisher }
  
  private let label: UILabel = {
    let label = UILabel()
    label.attributedText = "SNS 간편 로그인".attributedString(
      font: .body1Bold,
      color: .gray900
    )
    return label
  }()
  
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.spacing = 20
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.alignment = .center
    
    return stackView
  }()
  
  private let appleLoginButton = RoundImageButton(image: .appleBlack)
  private let kakaoLoginButton = RoundImageButton(image: .kakaoTalk)
  private let googleLoginButton = RoundImageButton(image: .google)

  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension OAuthLogInView {
  func setupUI() {
    setViewHeirarchy()
    setConstraints()
  }
  
  func setViewHeirarchy() {
    addSubviews(label, stackView)
    stackView.addArrangedSubviews(appleLoginButton, kakaoLoginButton, googleLoginButton)
  }
  
  func setConstraints() {
    label.snp.makeConstraints {
      $0.top.centerX.equalToSuperview()
    }
    
    stackView.snp.makeConstraints {
      $0.centerX.bottom.equalToSuperview()
      $0.top.equalTo(label.snp.bottom).offset(12)
      $0.height.equalTo(40)
    }
  }
}
