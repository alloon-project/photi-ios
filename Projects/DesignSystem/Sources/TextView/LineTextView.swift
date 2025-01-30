//
//  LineTextView.swift
//  DesignSystem
//
//  Created by jung on 5/9/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core

/// 여러 줄이 입력가능한 TextView입니다.
public final class LineTextView: UIView {
  /// Line Text View의 type입니다.
  public let type: TextViewType
  
  /// Line Text View의 mode입니다.
  public var mode: TextViewMode {
    didSet {
      textView.setLineColor(lineColor(for: mode))
    }
  }
  
  public var placeholder: String? {
    get { textView.placeholder }
    set { textView.placeholder = newValue }
  }
  
  public var text: String? {
    get { textView.text }
    set { textView.text = newValue }
  }
  
  // MARK: - UI Components
  public let textView = PhotiTextView()
  private lazy var countLabel = UILabel()
  private lazy var commentStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.spacing = 16
    stackView.alignment = .leading
    stackView.distribution = .fillProportionally
    
    return stackView
  }()
  
  public lazy var commentViews = [CommentView]() {
    didSet {
      oldValue.forEach {
        $0.removeFromSuperview()
        commentStackView.removeArrangedSubview($0)
      }
      
      commentViews.forEach { commentStackView.addArrangedSubview($0) }
    }
  }
  
  // MARK: - Initializers
  public init(type: TextViewType, mode: TextViewMode = .default) {
    self.type = type
    self.mode = mode
    super.init(frame: .zero)
    
    setupUI()
    textView.delegate = self
  }
  
  public convenience init(
    placeholder: String,
    text: String = "",
    type: TextViewType,
    mode: TextViewMode = .default
  ) {
    self.init(type: type, mode: mode)
    self.text = text
    self.placeholder = placeholder
        
    textView.type = text.isEmpty ? .placeholder : .text
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension LineTextView {
  func setupUI() {
    setViewHierarchy(for: type)
    setConstraints(for: type)
    
    if case let .count(max) = type {
      setCountLabel(max: max)
    }
    textView.setLineColor(lineColor(for: mode))
  }
  
  func setViewHierarchy(for type: TextViewType) {
    self.addSubview(textView)
    
    switch type {
      case .helper:
        self.addSubview(commentStackView)
        commentViews.forEach { commentStackView.addArrangedSubview($0) }
        
      case .count:
        self.addSubview(countLabel)
        
      default: break
    }
  }
  
  func setConstraints(for type: TextViewType) {
    switch type {
      case .default:
        textView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
      case .helper:
        textView.snp.makeConstraints { $0.leading.trailing.top.equalToSuperview() }
        commentStackView.snp.makeConstraints {
          $0.top.equalTo(textView.snp.bottom).offset(10)
          $0.bottom.leading.equalToSuperview()
        }
        
      case .count:
        textView.snp.makeConstraints { $0.leading.trailing.top.equalToSuperview() }
        countLabel.snp.makeConstraints {
          $0.top.equalTo(textView.snp.bottom).offset(10)
          $0.trailing.bottom.equalToSuperview()
        }
    }
  }
}

// MARK: - Private Methods
private extension LineTextView {
  func lineColor(for mode: TextViewMode) -> UIColor {
    switch mode {
      case .default:
        return textView.isEditing ? .blue400 : .gray200
      case .success:
        return .blue400
      case .error:
        return .red400
    }
  }
  
  func setCountLabel(max: Int) {
    countLabel.attributedText = "\(text?.count ?? 0)/\(max)"
      .attributedString(
        font: .caption1,
        color: .gray600
      )
  }
}

// MARK: - UITextViewDelegate
extension LineTextView: UITextViewDelegate {
  public func textViewDidBeginEditing(_ textView: UITextView) {
    self.textView.setLineColor(lineColor(for: mode))
    
    if self.textView.type == .placeholder {
      self.textView.text = ""
      self.textView.type = .text
    }
  }
  
  public func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      self.textView.type = .placeholder
    }
    
    self.textView.setLineColor(lineColor(for: mode))
  }
  
  public func textViewDidChange(_ textView: UITextView) {
    self.textView.text = textView.text
    
    if case let .count(max) = type {
      textView.text = (textView.text ?? "").trimmingPrefix(count: max)
      setCountLabel(max: max)
    }
  }
}

// MARK: - Reactive Extension
public extension Reactive where Base: LineTextView {
  var text: ControlProperty<String> {
    return base.textView.rx.text.orEmpty
  }
  
  var mode: Binder<TextViewMode> {
    return Binder(base) { base, mode in
      base.mode = mode
    }
  }
}
