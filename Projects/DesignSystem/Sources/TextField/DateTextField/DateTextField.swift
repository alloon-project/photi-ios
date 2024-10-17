//
//  DateTextField.swift
//  DesignSystem
//
//  Created by jung on 5/16/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core

public final class DateTextField: UIView {
  /// Date Text Field의 type입니다.
  public let type: DateTextFieldType
  
  /// Date Text Field의 mode입니다.
  public var mode: TextFieldMode {
    didSet {
      textField.setLineColor(lineColor(for: mode))
    }
  }
  
  /// rightView에 위치한 버튼의 text를 설정할 수 있씁니다.
  public var buttonText: String = "달력보기" {
    didSet {
      button.setText(buttonText, for: .normal)
    }
  }
  
  private var text: String? {
    textField.text
  }
  
  /// `DateTextField`에서 사용하는 placeholder입니다.
  private var placeholder = "YYYY.MM.DD"
  
  /// 현재 `text` 중 `placeholder`를 제외한 텍스트입니다.
  private var currentText: String {
    get {
      textField.currentText
    }
    set {
      textField.currentText = newValue
    }
  }
  
  /// 현재 입력된 `text`입니다. `currentText` 중 . 을 제외한 텍스트입니다.
  private var enteredText: String = ""

  /// 텍스트 삭제인지 추가인지 구별하기 위해 이전 상태 값을 저장합니다.
  private var previousText: String = ""
  
  public let startDate: Date
  
  /// 입력한 날짜입니다. 
  public var endDate: Date? {
    didSet {
      guard let endDate else { return }
      let dateString = endDate.toString("yyyy.MM.dd")
      self.setAttributedText(dateString)
    }
  }
  
  // MARK: - UI Components
  private let textField: PhotiDateTextField = {
    let textField = PhotiDateTextField()
    textField.keyboardType = .numberPad
    textField.autocorrectionType = .no
    textField.spellCheckingType = .no
    return textField
  }()
  
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
  
  fileprivate let button = FilledRoundButton(type: .primary, size: .xSmall)
  
  // MARK: - Initalizers
  public init(
    startDate: Date,
    type: DateTextFieldType,
    mode: TextFieldMode = .default
  ) {
    self.startDate = startDate
    self.type = type
    self.mode = mode
    
    super.init(frame: .zero)
    
    setupUI()
    setTextFieldTarget()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension DateTextField {
  func setupUI() {
    setViewHierarchy(for: type)
    setConstraints(for: type)
    setLeftView(textField, date: startDate)
    setRightView(textField)
    textField.setLineColor(lineColor(for: mode))
    textField.attributedText = placeholder.attributedString(
      font: .body2,
      color: .gray400
    )
    button.setText(buttonText, for: .normal)
  }
  
  func setViewHierarchy(for type: DateTextFieldType) {
    self.addSubview(textField)
    
    if case .helper = type {
      self.addSubview(commentStackView)
      commentViews.forEach { commentStackView.addArrangedSubview($0) }
    }
  }
  
  func setConstraints(for type: DateTextFieldType) {
    switch type {
      case .default:
        textField.snp.makeConstraints { $0.edges.equalToSuperview() }
        
      case .helper:
        textField.snp.makeConstraints { $0.leading.trailing.top.equalToSuperview() }
        commentStackView.snp.makeConstraints {
          $0.top.equalTo(textField.snp.bottom).offset(10)
          $0.bottom.leading.equalToSuperview()
        }
    }
  }
  
  func setRightView(_ textField: PhotiTextField) {
    textField.setRightView(
      button,
      size: button.intrinsicContentSize,
      leftPdding: 8,
      rightPadding: 6
    )
  }
  
  func setLeftView(_ textField: PhotiTextField, date: Date) {
    let startDateLabel = UILabel()
    let text = date.toString("yyyy.MM.dd")
    
    startDateLabel.attributedText = text.attributedString(
      font: .body2,
      color: .photiBlack
    )
    
    let label = UILabel()
    label.attributedText = "~".attributedString(font: .body2, color: .gray400)
    
    let leftViewSize = CGSize(
      width: label.intrinsicContentSize.width + startDateLabel.intrinsicContentSize.width + 4,
      height: label.intrinsicContentSize.height
    )
    
    let leftView = UIView(
      frame: .init(
        origin: .zero,
        size: leftViewSize
      )
    )
    leftView.addSubviews(startDateLabel, label)
    
    startDateLabel.frame = .init(origin: .zero, size: startDateLabel.intrinsicContentSize)
    
    let labelOrigin = CGPoint(x: startDateLabel.intrinsicContentSize.width + 4, y: 0)
    label.frame = .init(origin: labelOrigin, size: label.intrinsicContentSize)
    
    textField.setLeftView(
      leftView,
      size: leftViewSize,
      leftPdding: 16,
      rightPadding: 4
    )
  }
}

// MARK: - Private Methods
private extension DateTextField {
  func setTextFieldTarget() {
    textField.removeDefaultTarget()
    
    textField.addTarget(
      self,
      action: #selector(textDidChange),
      for: .editingChanged
    )
    
    textField.addTarget(
      self,
      action: #selector(isEditingChange),
      for: [.editingDidEnd, .editingDidBegin]
    )
  }
  
  @objc func isEditingChange() {
    textField.setLineColor(lineColor(for: mode))
  }
  
  @objc func textDidChange() {
    guard let text else { return }
    setEnteredText(text)
    setCurrentText()
    setText()
    setTextPosition(offSet: currentText.count)
  }
  
  func setEnteredText(_ text: String) {
    // 삭제한 경우,
    if previousText.count >= text.count && !enteredText.isEmpty {
      enteredText.removeLast()
    // 추가한 경우
    } else if
      previousText.count < text.count,
      text.count > currentText.count,
      enteredText.count < 8 {
      let index = text.index(text.startIndex, offsetBy: currentText.count)
      
      enteredText.append(text[index])
    }
  }
  
  func setCurrentText() {
    if enteredText.count < 4 {
      currentText = enteredText
    } else if enteredText.count < 6 {
      let index = enteredText.index(enteredText.startIndex, offsetBy: 4)
      currentText = String(enteredText[..<index]) + "." + String(enteredText[index...])
    } else {
      let indexYear = enteredText.index(enteredText.startIndex, offsetBy: 4)
      let indexMonth = enteredText.index(enteredText.startIndex, offsetBy: 6)
      
      currentText = String(enteredText[..<indexYear]) + "."
      + String(enteredText[indexYear..<indexMonth]) + "."
      + String(enteredText[indexMonth...])
    }
  }
  
  func setText() {
    var newText: String = ""
    
    if enteredText.count == 8 {
      newText = currentText
      setAttributedText(newText)
      
      self.endDate = currentText.toDate()
    } else {
      let index = placeholder.index(placeholder.startIndex, offsetBy: currentText.count)
      newText = currentText + String(placeholder[index...])
      
      setAttributedText(newText, placeholderIndex: index)
      
      self.endDate = nil
    }
    
    previousText = newText
  }
  
  func setAttributedText(_ text: String) {
    textField.attributedText = text.attributedString(
      font: .body2,
      color: .photiBlack
    )
  }
  
  func setAttributedText(_ text: String, placeholderIndex: String.Index) {
    textField.attributedText = text.attributedString(
      font: .body2,
      color: .photiBlack
    )
    .setColor(.gray400, for: String(placeholder[placeholderIndex...]))
  }
  
  func setTextPosition(offSet: Int) {
    guard let position = textField.position(
      from: textField.beginningOfDocument,
      offset: offSet
    ) else { return }
    textField.selectedTextRange = textField.textRange(from: position, to: position)
  }
  
  func lineColor(for mode: TextFieldMode) -> UIColor {
    switch mode {
      case .default, .success:
        return textField.isEditing ? .blue400 : .gray200
      case .error:
        return .red400
    }
  }
}

// MARK: - Reactive Extension
public extension Reactive where Base: DateTextField {
  var didTapButton: ControlEvent<Void> {
    return base.button.rx.tap
  }
}
