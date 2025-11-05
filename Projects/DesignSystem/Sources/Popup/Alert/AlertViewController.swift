//
//  AlertViewController.swift
//  DesignSystem
//
//  Created by jung on 5/10/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Combine
import SnapKit
import Core

final public class AlertViewController: UIViewController {
  public private(set) var isPresenting: Bool = false
  
  // MARK: - AlertType
  /// Alert의 버튼 갯수를 정의합니다.
  public enum AlertType {
    case confirm
    case canCancel
  }
  
  // MARK: - Properties
  public var confirmButtonTitle: String = "확인" {
    didSet { confirmButton.setText(confirmButtonTitle) }
  }
  
  public var cancelButtonTitle: String = "취소" {
    didSet { cancelButton.setText(cancelButtonTitle) }
  }
  
  public var didTapConfirmButton: AnyPublisher<Void, Never> { confirmButton.tapPublisher }
  public var didTapCancelButton: AnyPublisher<Void, Never> { cancelButton.tapPublisher }

  private var cancellables: Set<AnyCancellable> = []
  private let type: AlertType
  private let mainTitle: String
  private let subTitle: String?
  private let shouldDismissOnConfirm: Bool
  
  // MARK: - UI Components
  private let dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4)
    view.layer.compositingFilter = "multiplyBlendMode"
    
    return view
  }()
  
  private let mainContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .photiWhite
    view.layer.cornerRadius = 16
    view.clipsToBounds = true
    
    return view
  }()
  
  private let mainTitleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  private lazy var subTitleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  fileprivate let confirmButton: FilledRoundButton
  fileprivate lazy var cancelButton: FilledRoundButton = FilledRoundButton(type: .quaternary, size: .small, text: "취소")
  
  // MARK: - Initializers
  public init(
    alertType: AlertType,
    title: String,
    subTitle: String? = nil,
    shouldDismissOnConfirm: Bool = true,
  ) {
    self.type = alertType
    self.mainTitle = title
    self.subTitle = subTitle
    self.shouldDismissOnConfirm = shouldDismissOnConfirm
    
    // alertType에 따라 button의 사이즈가 달라집니다.
    switch alertType {
      case .confirm:
        self.confirmButton = FilledRoundButton(type: .primary, size: .large, text: "확인")
      case .canCancel:
        self.confirmButton = FilledRoundButton(type: .primary, size: .small, text: "확인")
    }
    
    super.init(nibName: nil, bundle: nil)
    
    setupUI()
    bind()
  }
  
  public convenience init(
    alertType: AlertType,
    title: String,
    attributedSubTitle: NSAttributedString,
    shouldDismissOnConfirm: Bool = true
  ) {
    self.init(alertType: alertType, title: title, subTitle: "", shouldDismissOnConfirm: shouldDismissOnConfirm)
    subTitleLabel.attributedText = attributedSubTitle
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    isPresenting = true
  }
  
  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    isPresenting = false
  }
}

// MARK: - UI Methods
private extension AlertViewController {
  func setupUI() {
    setViewHierarchy(for: type)
    setConstraints(for: type)
    
    setMainTitle(mainTitle)
    if let subTitle = subTitle {
      setSubTitle(subTitle)
    }
  }
  
  func setViewHierarchy(for type: AlertType) {
    view.addSubviews(dimmedView, mainContainerView)
    mainContainerView.addSubview(mainTitleLabel)
    
    if subTitle != nil {
      mainContainerView.addSubview(subTitleLabel)
    }
    
    switch type {
      case .confirm:
        mainContainerView.addSubview(confirmButton)
      case .canCancel:
        mainContainerView.addSubviews(confirmButton, cancelButton)
    }
  }
  
  func setConstraints(for type: AlertType) {
    dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }
   
    mainContainerView.snp.makeConstraints { $0.center.equalToSuperview() }
    
    mainTitleLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().offset(40)
    }
    
    if subTitle != nil {
      subTitleLabel.snp.makeConstraints {
        $0.centerX.equalToSuperview()
        $0.top.equalTo(mainTitleLabel.snp.bottom).offset(16)
      }
    }
    
    // subTitle이 존재하는 경우, subTitleLabel의 bottom으로
    // 반대의 경우 mainTitleLabel의 bottom으로 지정합니다.
    let buttonConstraintTarget = (subTitle == nil) ? mainTitleLabel.snp.bottom : subTitleLabel.snp.bottom
    let buttonOffset = (subTitle == nil) ? 24 : 32
    
    switch type {
      case .confirm:
        confirmButton.snp.makeConstraints {
          $0.leading.trailing.bottom.equalToSuperview().inset(16)
          $0.top.equalTo(buttonConstraintTarget).offset(buttonOffset)
        }
      case .canCancel:
        cancelButton.snp.makeConstraints {
          $0.leading.bottom.equalToSuperview().inset(16)
          $0.top.equalTo(buttonConstraintTarget).offset(buttonOffset)
        }
        
        confirmButton.snp.makeConstraints {
          $0.trailing.equalToSuperview().inset(16)
          $0.centerY.equalTo(cancelButton)
          $0.leading.equalTo(cancelButton.snp.trailing).offset(7)
        }
    }
  }
}

// MARK: - Bind Methods
private extension AlertViewController {
  func bind() {
    confirmButton.tapPublisher
      .sinkOnMain(with: self) { owner, _ in
        owner.confirmButtonDidTap()
      }.store(in: &cancellables)
    
    if case .canCancel = type {
      cancelButton.tapPublisher
        .sinkOnMain(with: self) { owner, _ in
          owner.confirmButtonDidTap()
        }.store(in: &cancellables)
    }
  }
}

// MARK: - Public Methods
public extension AlertViewController {
  func present(
    to viewController: UIViewController,
    animted: Bool,
    completion: (() -> Void)? = nil
  ) {
    self.modalPresentationStyle = .overFullScreen
    self.modalTransitionStyle = .crossDissolve
    viewController.present(self, animated: true, completion: completion)
  }
  
  func setConfirmButtonText(_ text: String) {
    confirmButton.setText(text)
  }
  
  func setCancelButtonText(_ text: String) {
    guard case .canCancel = type else { return }
    
    cancelButton.setText(text)
  }
}

// MARK: - Private Methods
private extension AlertViewController {
  func setMainTitle(_ text: String) {
    self.mainTitleLabel.attributedText = text.attributedString(
      font: .heading4,
      color: .gray900
    )
  }
  
  func setSubTitle(_ text: String) {
    self.subTitleLabel.attributedText = text.attributedString(
      font: .body2,
      color: .gray600,
      alignment: .center
    )
  }
  
  func confirmButtonDidTap() {
    if shouldDismissOnConfirm {
      self.dismiss(animated: true)
    }
  }
  
  func cancelButtonDidTap() {
    self.dismiss(animated: true)
  }
}
