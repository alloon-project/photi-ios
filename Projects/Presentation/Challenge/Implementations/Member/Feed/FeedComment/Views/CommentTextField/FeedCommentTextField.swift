//
//  FeedCommentTextField.swift
//  Presentation
//
//  Created by jung on 12/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CoreUI
import DesignSystem

final class FeedCommentTextField: UIView {
  enum Constants {
    static let maxTextCount = 16
  }
  // MARK: - Properties
  var text: String {
    get { textField.text ?? "" }
    set {
      setTextCountLabel(newValue.count)
      textField.text = newValue
    }
  }
  
  // MARK: - UI Components
  fileprivate let textField = LeftImageTextField()
  private let textCountLabel = UILabel()
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
    
    textField.addTarget(
      self,
      action: #selector(textDidChange),
      for: .editingChanged
    )
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension FeedCommentTextField {
  func setupUI() {
    setViewHeirarchy()
    setConstraints()
    setTextCountLabel(0)
  }
  
  func setViewHeirarchy() {
    addSubviews(textField, textCountLabel)
  }
  
  func setConstraints() {
    textField.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview()
      $0.height.equalTo(42)
    }
    
    textCountLabel.snp.makeConstraints {
      $0.trailing.bottom.equalToSuperview()
      $0.top.equalTo(textField.snp.bottom).offset(8)
    }
  }
}

// MARK: - Private Methods
private extension FeedCommentTextField {
  @objc func textDidChange() {
    textField.text = text.trimmingPrefix(count: Constants.maxTextCount)
    setTextCountLabel(text.count)
  }
  
  func setTextCountLabel(_ count: Int) {
    textCountLabel.attributedText = "\(count)/\(Constants.maxTextCount)".attributedString(
      font: .caption1,
      color: .gray600
    )
  }
}

// MARK: - Reactive Extension
extension Reactive where Base: FeedCommentTextField {
  var didBeginInitialEditing: ControlEvent<Void> {
    let event = base.textField.rx.controlEvent(.editingDidBegin).take(1)
    
    return ControlEvent(events: event)
  }
  
  var didTapReturn: ControlEvent<Void> {
    let event = base.textField.rx.controlEvent(.editingDidEndOnExit)
    
    return ControlEvent(events: event)
  }
}
