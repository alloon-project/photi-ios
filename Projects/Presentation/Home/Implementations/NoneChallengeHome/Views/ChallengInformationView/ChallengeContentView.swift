//
//  ChallengeContentView.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class ChallengeContentView: UIView {
  enum ContentCount {
    case one(title: String), two(firstTitle: String, secondTitle: String)
  }
  
  // MARK: - Properties
  let contentCount: ContentCount
  
  // MARK: - UI Components
  private let firstTitleLabel = UILabel()
  private let firstContentTextView: UITextView = {
    let textView = UITextView()
    textView.isEditable = false
    textView.textContainer.lineFragmentPadding = 0
    textView.textContainerInset = .zero
    
    return textView
  }()
  
  private lazy var secondTitleLabel = UILabel()
  private lazy var secondContentTextView: UITextView = {
    let textView = UITextView()
    textView.isEditable = false
    textView.textContainer.lineFragmentPadding = 0
    textView.textContainerInset = .zero
    
    return textView
  }()
  
  // MARK: - Initializers
  init(contentCount: ContentCount) {
    self.contentCount = contentCount
    super.init(frame: .zero)
    
    setupUI(for: contentCount)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if case .two = contentCount { drawDottedLineAtCenter() }
  }
  
  // MARK: - Configure Methods
  func configure(firstContent: String, secondContent: String? = nil) {
    switch contentCount {
      case .two:
        setContent(secondContent ?? "", textView: secondContentTextView)
        setContent(firstContent, textView: firstContentTextView)
      case .one:
        setContent(firstContent, textView: firstContentTextView)
    }
  }
}

// MARK: - UI Methods
private extension ChallengeContentView {
  func setupUI(for type: ContentCount) {
    layer.cornerRadius = 12
    layer.borderWidth = 1
    layer.borderColor = UIColor.gray300.cgColor
    
    setViewHierarchy(for: type)
    setConstraints(for: type)
    
    switch type {
      case let .one(title):
        setTitle(title, label: firstTitleLabel)
      case let .two(firstTitle, secondTitle):
        [firstContentTextView, secondContentTextView].forEach { $0.isScrollEnabled = false }
        setTitle(firstTitle, label: firstTitleLabel)
        setTitle(secondTitle, label: secondTitleLabel)
    }
  }
  
  func setViewHierarchy(for type: ContentCount) {
    switch type {
      case .one:
        addSubviews(firstTitleLabel, firstContentTextView)
      case .two:
        addSubviews(firstTitleLabel, firstContentTextView, secondTitleLabel, secondContentTextView)
    }
  }
  
  func setConstraints(for type: ContentCount) {
    switch type {
      case .one:
        setConstraintsForOneContent()
      case .two:
        setConstraintsforTwoContent()
    }
  }
  
  func setConstraintsForOneContent() {
    firstTitleLabel.snp.makeConstraints {
      $0.leading.top.equalToSuperview().offset(14)
    }
    
    firstContentTextView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview().inset(14)
      $0.top.equalTo(firstTitleLabel.snp.bottom).offset(6)
    }
  }
  
  func setConstraintsforTwoContent() {
    firstTitleLabel.snp.makeConstraints {
      $0.leading.top.equalToSuperview().offset(14)
    }
    
    firstContentTextView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(14)
      $0.top.equalTo(firstTitleLabel.snp.bottom).offset(6)
    }
    
    secondTitleLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(14)
      $0.top.equalTo(firstContentTextView.snp.bottom).offset(25)
    }
    
    secondContentTextView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview().inset(14)
      $0.top.equalTo(secondTitleLabel.snp.bottom).offset(6)
      $0.height.equalTo(12)
    }
  }
}

// MARK: - Private Methods
private extension ChallengeContentView {
  func drawDottedLineAtCenter() {
    let startPoint = CGPoint(x: 14, y: frame.height / 2)
    let endPoint = CGPoint(x: frame.width - 14, y: frame.height / 2)
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.strokeColor = UIColor.gray300.cgColor
    shapeLayer.lineWidth = 1
    shapeLayer.lineDashPattern = [3, 3]
    
    let path = CGMutablePath()
    path.addLines(between: [startPoint, endPoint])
    shapeLayer.path = path
    layer.addSublayer(shapeLayer)
  }
  
  func setTitle(_ title: String, label: UILabel) {
    label.attributedText = title.attributedString(font: .caption1Bold, color: .gray800)
  }
  
  func setContent(_ content: String, textView: UITextView) {
    textView.attributedText = content.attributedString(font: .body2, color: .gray700)
  }
}
