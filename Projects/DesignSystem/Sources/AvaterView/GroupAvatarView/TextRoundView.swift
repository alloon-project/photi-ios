//
//  TextRoundView.swift
//  DesignSystem
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

final class TextRoundView: UIView {
  typealias TextRoundViewSize = GroupAvatarView.GroupAvatarSize
  // MARK: - Properties
  override var intrinsicContentSize: CGSize { return cgSize(for: size) }
  
  let size: TextRoundViewSize
  
  // MARK: - UI Components
  private let countLabel = UILabel()
  
  // MARK: - Initializers
  init(size: TextRoundViewSize, count: Int = 0) {
    self.size = size
    super.init(frame: .zero)
    setupUI()
    configureCountLabel(count)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - layoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.cornerRadius = frame.width / 2
  }
}

// MARK: - UI Methods
private extension TextRoundView {
  func setupUI() {
    self.clipsToBounds = true
    self.backgroundColor = .gray500
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.white.cgColor
    
    addSubview(countLabel)
    
    countLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}

// MARK: - Internal Methods
extension TextRoundView {
  func configureCountLabel(_ count: Int) {
    countLabel.attributedText = "+\(count)".attributedString(
      font: .caption2Bold,
      color: .gray0
    )
  }
}

// MARK: - Private Methods
private extension TextRoundView {
  func cgSize(for size: TextRoundViewSize) -> CGSize {
    switch size {
      case .small: return CGSize(width: 30, height: 30)
      case .xSmall: return CGSize(width: 24, height: 24)
    }
  }
}
