//
//  InvitationCodeViewController.swift
//  HomeImpl
//
//  Created by jung on 1/28/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import Core
import DesignSystem

protocol InvitationCodeViewControllerDelegate: AnyObject {
  func didTapUnlockButton(_ viewController: InvitationCodeViewController, code: String)
  func didDismiss()
}

final class InvitationCodeViewController: UIViewController {
  private let disposeBag = DisposeBag()
  weak var delegate: InvitationCodeViewControllerDelegate?
  var keyboardShowNotification:NSObjectProtocol?
  var keyboardHideNotification: NSObjectProtocol?
  
  // MARK: - UI Components
  private let dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4)
    view.layer.compositingFilter = "multiplyBlendMode"
    
    return view
  }()
  
  private let mainContentView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 16
    
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "초대코드를 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let codeTextField = InvitationCodeTextField(maximumCodeLength: 5)
  private let confirmButton = UnlockButton()
  
  // MARK: - Initializers
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bind()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    keyboardShowNotification = registerKeyboardShowNotification()
    keyboardHideNotification = registerKeyboardHideNotification()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentWithAnimation()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    removeKeyboardNotification(keyboardShowNotification, keyboardHideNotification)
  }
}

// MARK: - UI Methods
private extension InvitationCodeViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(dimmedView, mainContentView)
    mainContentView.addSubviews(titleLabel, codeTextField, confirmButton)
  }
  
  func setConstraints() {
    dimmedView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    mainContentView.snp.makeConstraints {
      $0.width.equalTo(311)
      $0.height.equalTo(211)
      $0.center.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(38)
      $0.centerX.equalToSuperview()
    }
    
    codeTextField.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(14)
      $0.leading.trailing.equalToSuperview().inset(12)
      $0.height.equalTo(48)
    }
    
    confirmButton.snp.makeConstraints {
      $0.width.height.equalTo(56)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(16)
    }
  }
}

// MARK: - Bind Methods
private extension InvitationCodeViewController {
  func bind() {
    dimmedView.rx.tapGesture()
      .when(.recognized)
      .bind(with: self) { owner, _ in
        if owner.codeTextField.isEditing {
          owner.view.endEditing(true)
        } else {
          owner.dismissWithAnimation()
        }
      }
      .disposed(by: disposeBag)
    
    codeTextField.rx.text
      .compactMap { $0 }
      .bind(with: self) { owner, text in
        owner.didChangeVerificationCode(text)
      }
      .disposed(by: disposeBag)
    
    confirmButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    confirmButton.rx.tap
      .withLatestFrom(codeTextField.rx.text)
      .compactMap { $0 }
      .bind(with: self) { owner, code in
        owner.delegate?.didTapUnlockButton(owner, code: code)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Internal Methods
extension InvitationCodeViewController {
  func convertToUnlock() {
    confirmButton.isLocked = false
    dismiss(animated: false) {
      self.delegate?.didDismiss()
    }
  }
  
  func displayToastView() {
    let toastView = ToastView(tipPosition: .none, text: "초대코드가 일치하지 않아요", icon: .bulbWhite)
    toastView.setConstraints {
      $0.bottom.equalToSuperview().inset(64)
      $0.centerX.equalToSuperview()
    }
    
    toastView.present(to: self)
  }
}

// MARK: - KeyboardListener
extension InvitationCodeViewController: KeyboardListener {
  func keyboardWillShow(keyboardHeight: CGFloat) {
    let keyBoardMinY = view.frame.height - keyboardHeight
    let mainContentViewMaxY = mainContentView.frame.maxY
    
    guard keyBoardMinY - mainContentViewMaxY < 24 else { return }
    let translataionY = keyBoardMinY - mainContentViewMaxY - 24

    mainContentView.transform = CGAffineTransform(
      translationX: 0,
      y: translataionY
    )
  }
  
  func keyboardWillHide() {
    mainContentView.transform = .identity
  }
}

// MARK: - Private Methods
private extension InvitationCodeViewController {
  func presentWithAnimation() {
    mainContentView.frame.origin.y = view.frame.height
    UIView.animate(withDuration: 0.4) {
      self.mainContentView.center.y = self.view.center.y
      self.mainContentView.layoutIfNeeded()
    }
  }
  
  func dismissWithAnimation() {
    UIView.animate(withDuration: 0.4) {
      self.mainContentView.frame.origin.y = self.view.frame.height
      self.mainContentView.layoutIfNeeded()
    } completion: { _ in
      self.dismiss(animated: false) {
        self.delegate?.didDismiss()
      }
    }
  }
  
  func didChangeVerificationCode(_ code: String) {
    confirmButton.isEnabled = code.count == 5
    confirmButton.isLocked = true
  }
}
