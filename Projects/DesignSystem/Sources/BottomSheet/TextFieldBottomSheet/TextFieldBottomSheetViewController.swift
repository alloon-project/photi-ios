//
//  TextFieldBottomSheetViewController.swift
//  DesignSystem
//
//  Created by jung on 5/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Combine
import RxCocoa
import RxSwift
import SnapKit
import Core

public protocol TextFieldBottomSheetDelegate: AnyObject {
  func didTapCloseButton()
  func didTapConfirmButton(_ text: String)
}

public final class TextFieldBottomSheetViewController: BottomSheetViewController {
  private let disposeBag = DisposeBag()
  private var cancellables: Set<AnyCancellable> = []
  
  public weak var delegate: TextFieldBottomSheetDelegate?
  
  public var titleText: String {
    didSet {
      self.setTitleLabel(titleText)
    }
  }
  
  public var buttonText: String {
    didSet { button.title = buttonText }
  }
  
  public var buttonMode: ButtonMode {
    get { button.mode }
    set { button.mode = newValue }
  }
  
  public var commentViews: [CommentView] {
    get { textField.commentViews }
    set { textField.commentViews = newValue }
  }
  
  public var placeholder: String? {
    get { textField.placeholder }
    set { textField.placeholder = newValue }
  }
  
  public var textFieldText: String? {
    get { textField.text }
    set { textField.text = newValue }
  }
  
  // MARK: - UI Components
  private let headerView = UIView()
  private let titleLabel = UILabel()
  
  private let closeButton: UIButton = {
    let button = UIButton()
    button.setImage(.closeCircleLight, for: .normal)
    button.layer.cornerRadius = 12
    
    return button
  }()
  
  public let textField: LineTextField
  public let button = FilledRoundButton(type: .primary, size: .xLarge)
  
  // MARK: - Initializers
  public init(
    textFieldType: TextFieldType,
    title: String = "",
    button: String = ""
  ) {
    self.textField = LineTextField(type: textFieldType)
    self.titleText = title
    self.buttonText = button
    super.init(nibName: nil, bundle: nil)
  }
  
  public convenience init(
    textFieldType: TextFieldType,
    title: String = "",
    button: String = "",
    text: String = "",
    placeholder: String
  ) {
    self.init(textFieldType: textFieldType, title: title, button: button)
    self.textFieldText = text
    self.placeholder = placeholder
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    bind()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerKeyboardNotification()
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeKeyboardNotification()
    textFieldText = nil
  }
}

// MARK: - UI Methods
private extension TextFieldBottomSheetViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    
    setTitleLabel(titleText)
    button.title = buttonText
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(headerView, textField, button)
    headerView.addSubviews(titleLabel, closeButton)
  }
  
  func setConstraints() {
    contentView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().offset(-56)
      $0.top.equalToSuperview().offset(28)
    }
    
    headerView.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview()
      $0.height.equalTo(32)
    }
    
    titleLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    
    closeButton.snp.makeConstraints {
      $0.trailing.equalToSuperview()
      $0.centerY.equalToSuperview()
    }
    
    textField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(headerView.snp.bottom).offset(32)
    }
    
    button.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom).offset(174)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }
}

// MARK: - Bind
private extension TextFieldBottomSheetViewController {
  func bind() {
    closeButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.delegate?.didTapCloseButton()
        owner.dismissBottomSheet()
        owner.didDismiss.accept(())
      }
      .disposed(by: disposeBag)
    
    button.rx.tap
      .bind(with: self) { owner, _ in
        owner.delegate?.didTapConfirmButton(owner.textFieldText ?? "")
        owner.dismissBottomSheet()
      }
      .disposed(by: disposeBag)
    
    textField.textPublisher
      .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .assign(to: \.isEnabled, on: button)
      .store(in: &cancellables)
  }
}

// MARK: - Private Methods
private extension TextFieldBottomSheetViewController {
  func registerKeyboardNotification() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  func removeKeyboardNotification() {
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  @objc func keyboardWillShow(_ notification: Notification) {
    guard
      let userInfo: NSDictionary = notification.userInfo as? NSDictionary,
      let keyboardFrame = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue
    else { return }
    
    let keyboardRectangle = keyboardFrame.cgRectValue
    self.isKeyboardDisplay = true
    self.view.transform = CGAffineTransform(
      translationX: 0,
      y: view.frame.origin.y - keyboardRectangle.height
    )
  }
  
  @objc func keyboardWillHide(_ notification: Notification) {
    self.isKeyboardDisplay = false
    self.view.transform = .identity
  }
  
  func setTitleLabel(_ text: String) {
    titleLabel.attributedText = text.attributedString(
      font: .body1Bold,
      color: .gray900
    )
  }
}
