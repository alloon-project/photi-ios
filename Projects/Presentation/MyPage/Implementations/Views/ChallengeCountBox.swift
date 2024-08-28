//
//  ChallengeCountBox.swift
//  LogInImpl
//
//  Created by jung on 7/21/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ChallengeCountBox: UIView {
  // MARK: - Properties
  var title: String {
    didSet { setTitleLabel(title) }
  }
  
  var count: Int {
    didSet { setCountLabel("\(count)") }
  }

  // MARK: - UI Components
  private let titleLabel = UILabel()
  private let countLabel = UILabel()
  
  // MARK: - Initializers
  init(title: String = "", count: Int = 0) {
    self.title = title
    self.count = count
    super.init(frame: .zero)
    self.setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension ChallengeCountBox {
  func setupUI() {
    self.backgroundColor = .blue400
    self.layer.cornerRadius = 8
    setViewHierarchy()
    setConstraints()
    setTitleLabel(title)
    setCountLabel("\(count)")
  }
  
  func setViewHierarchy() {
    self.addSubviews(titleLabel, countLabel)
  }

  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().offset(20)
    }
    
    countLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(12)
      $0.bottom.equalToSuperview().offset(-21)
    }
  }
}

// MARK: - Private Methods
private extension ChallengeCountBox {
  func setTitleLabel(_ text: String) {
    titleLabel.attributedText = text.attributedString(font: .body2Bold, color: .white)
  }
  
  func setCountLabel(_ text: String) {
    countLabel.attributedText = text.attributedString(font: .heading1, color: .white)
  }
}

// MARK: - Reative Extension
extension Reactive where Base: ChallengeCountBox {
  var didTapBox: ControlEvent<Void> {
    let base = base.rx.tapGesture().when(.recognized).map { _ in }
    return ControlEvent(events: base)
  }
}
