//
//  FindView.swift
//  LogInImpl
//
//  Created by jung on 5/21/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Combine
import SnapKit
import Core
import DesignSystem

final class FindView: UIView {
  let findIdTapPublisher: AnyPublisher<Void, Never>
  let findPasswordTapPublisher: AnyPublisher<Void, Never>
  // MARK: - UI Components
  fileprivate let findIdButton = TextButton(text: "아이디 찾기", size: .xSmall, type: .gray)
  fileprivate let findPasswordButton = TextButton(text: "비밀번호 찾기", size: .xSmall, type: .gray)
  
  private let verticalLine: UIView = {
    let view = UIView()
    view.backgroundColor = .gray300
    
    return view
  }()
  
  // MARK: - Initializers
  init() {
    self.findIdTapPublisher = findIdButton.tapPublisher
    self.findPasswordTapPublisher = findPasswordButton.tapPublisher
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension FindView {
  func setupUI() {
    setViewHeirarchy()
    setConstraints()
  }
  
  func setViewHeirarchy() {
    self.addSubviews(findIdButton, verticalLine, findPasswordButton)
  }
  
  func setConstraints() {
    findIdButton.snp.makeConstraints {
      $0.leading.top.bottom.equalToSuperview()
    }
    
    verticalLine.snp.makeConstraints {
      $0.width.equalTo(1)
      $0.height.equalTo(10)
      $0.centerY.equalToSuperview()
      $0.leading.equalTo(findIdButton.snp.trailing).offset(8)
    }
    
    findPasswordButton.snp.makeConstraints {
      $0.leading.equalTo(verticalLine.snp.trailing).offset(8)
      $0.trailing.top.bottom.equalToSuperview()
    }
  }
}
