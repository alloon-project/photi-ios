//
//  ButtonTextField.swift
//  DesignSystem
//
//  Created by jung on 5/8/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Core

/// Button이 포함된 TextField입니다.
public final class ButtonTextField: LineTextField {
  public let button: FilledRoundButton
  
  public var buttonIsEnabled: Bool {
    get { button.isEnabled }
    set { button.isEnabled = newValue }
  }
  
  // MARK: - Initializers
  public init(
    buttonText: String,
    type: TextFieldType,
    mode: TextFieldMode = .default
  ) {
    self.button = FilledRoundButton(type: .primary, size: .xSmall, text: buttonText)
    button.invalidateIntrinsicContentSize()
    super.init(type: type, mode: mode)
  }
  
  public convenience init(
    buttonText: String,
    placeholder: String,
    text: String = "",
    type: TextFieldType,
    mode: TextFieldMode = .default
  ) {
    self.init(buttonText: buttonText, type: type, mode: mode)
    self.placeholder = placeholder
    self.text = text
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup UI
  override func setupUI() {
    super.setupUI()
    button.invalidateIntrinsicContentSize()

    self.textField.setRightView(
      button,
      size: button.intrinsicContentSize,
      leftPdding: 8,
      rightPadding: 6
    )
  }
}

// MARK: - Reactive Extensions
public extension Reactive where Base: ButtonTextField {
  var didTapButton: ControlEvent<Void> {
    base.button.rx.tap
  }
  
  var buttonIsEnabled: Binder<Bool> {
    .init(base) { base, value in
      base.buttonIsEnabled = value
    }
  }
}
