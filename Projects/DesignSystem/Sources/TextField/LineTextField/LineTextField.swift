//
//  TextField.swift
//  DesignSystem
//
//  Created by jung on 5/6/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core

/// 기본적인 TextField입니다. 
public class LineTextField: UIView {
  /// Line Text Field의 type입니다.
  public let type: TextFieldType
  
  /// Line Text Field의 mode입니다.
  public var mode: TextFieldMode {
    didSet {
      textField.setLineColor(lineColor(for: mode))
    }
  }
  
  public var placeholder: String? {
    get { textField.placeholder }
    set { textField.placeholder = newValue }
  }
  
  public var text: String? {
    get { textField.text }
    set { textField.text = newValue }
  }
  
  // MARK: - UI Components
  public let textField = AlloonTextField()
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
      
      if commentViews.isEmpty {
        removeCommentStackView()
      } else {
        setCommentStackView()
      }
    }
  }
  
  // MARK: - Initializers
  public init(type: TextFieldType, mode: TextFieldMode = .default) {
    self.type = type
    self.mode = mode
    super.init(frame: .zero)
    
    setupUI()
    setTextFieldTarget()
  }
  
  public convenience init(
    placeholder: String,
    text: String = "",
    type: TextFieldType,
    mode: TextFieldMode = .default
  ) {
    self.init(type: type, mode: mode)
    self.placeholder = placeholder
    self.text = text
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup UI
  func setupUI() {
    setViewHierarchy(for: type)
    setConstraints(for: type)
    if case let .count(max) = type {
      setCountLabel(max: max)
    }
    textField.setLineColor(lineColor(for: mode))
  }
  
  public func setKeyboardType(_ type : UIKeyboardType) {
    textField.keyboardType = type
  }
}

// MARK: - UI Methods
private extension LineTextField {
  func setViewHierarchy(for type: TextFieldType) {
    self.addSubview(textField)
    
    switch type {        
      case .count:
        self.addSubview(countLabel)
        
      default: break
    }
  }
  
  func setConstraints(for type: TextFieldType) {
    switch type {
      case .default, .helper:
        textField.snp.makeConstraints { $0.edges.equalToSuperview() }
        
      case .count:
        textField.snp.makeConstraints { $0.leading.trailing.top.equalToSuperview() }
        countLabel.snp.makeConstraints {
          $0.top.equalTo(textField.snp.bottom).offset(12)
          $0.trailing.equalToSuperview()
          $0.bottom.equalToSuperview().offset(-1)
        }
    }
  }
}

// MARK: - Private Methods
private extension LineTextField {
  func setTextFieldTarget() {
    if case .count = type {
      textField.addTarget(
        self,
        action: #selector(textDidChange),
        for: .editingChanged
      )
    }
    
    textField.addTarget(
      self,
      action: #selector(isEditingChange),
      for: [.editingDidEnd, .editingDidBegin]
    )
  }
  
  @objc func textDidChange() {
    if case let .count(max) = type {
      textField.text = (text ?? "").trimmingSuffix(count: max)
      setCountLabel(max: max)
    }
  }
  
  @objc func isEditingChange() {
    textField.setLineColor(lineColor(for: mode))
  }
  
  func lineColor(for mode: TextFieldMode) -> UIColor {
    switch mode {
      case .default:
        return textField.isEditing ? .green400 : .gray200
      case .success:
        return .green400
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
  
  func setCommentStackView() {
    guard !self.subviews.contains(commentStackView) else { return }
    
    self.addSubview(commentStackView)
    textField.snp.remakeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }
    
    commentStackView.snp.makeConstraints {
      $0.top.equalTo(textField.snp.bottom).offset(10)
      $0.bottom.leading.equalToSuperview()
    }
  }
  
  func removeCommentStackView() {
    guard self.subviews.contains(commentStackView) else { return }
    commentStackView.snp.removeConstraints()
    commentStackView.removeFromSuperview()
    textField.snp.remakeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}

// MARK: - LineTextField
public extension Reactive where Base: LineTextField {
  var text: ControlProperty<String> {
    return base.textField.rx.text.orEmpty
  }
  
  var mode: Binder<TextFieldMode> {
    return Binder(base) { base, mode in
      base.mode = mode
    }
  }
}
