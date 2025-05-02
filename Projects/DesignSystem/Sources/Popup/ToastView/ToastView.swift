//
//  ToastView.swift
//  DesignSystem
//
//  Created by jung on 5/10/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

public final class ToastView: UIView {
  /// Tip의 위치를 나타냅니다.
  public enum TipPosition {
    case none
    case centerTop, centerBottom
    case leftTop, leftBottom
    case rightTop, rightBottom
  }
  
  /// toastView를 띄울 Constraint를 적용합니다.
  private var toastViewConstraints: ((ConstraintMaker) -> Void)?
  private let tipPosition: TipPosition
  private let text: String
  private let icon: UIImage
  private var isRemoved = false
  private var workItem: DispatchWorkItem?
  
  // MARK: - UI Compnents
  private let label = UILabel()
  private let iconView = UIImageView()
  private lazy var tipView: TipView? = nil
  
  // MARK: - Initializers
  public init(
    tipPosition: TipPosition,
    text: String,
    icon: UIImage = UIImage(systemName: "lightbulb.fill")!
  ) {
    self.tipPosition = tipPosition
    self.text = text
    self.icon = icon
    super.init(frame: .zero)
    
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - UIResponder Override
  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    self.remove()
  }
}

// MARK: - UI Methods
private extension ToastView {
  func setupUI() {
    self.backgroundColor = .gray900
    layer.cornerRadius = 16
    setTipView(for: tipPosition)
    setIconView(icon)
    setLabel(text)
    
    setViewHierarchy()
    setConstraints(for: tipPosition)
  }
  
  func setViewHierarchy() {
    addSubviews(label, iconView)
    
    if let tipView = tipView {
      addSubview(tipView)
    }
  }
  
  func setConstraints(for position: TipPosition) {
    iconView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(32)
      $0.top.bottom.equalToSuperview().inset(20)
      $0.width.height.equalTo(16)
    }
    
    label.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-32)
      $0.centerY.equalToSuperview()
      $0.leading.equalTo(iconView.snp.trailing).offset(8)
    }
    
    guard let tipView = tipView else { return }
    
    switch position {
      case .centerTop:
        tipView.snp.makeConstraints {
          $0.centerX.equalToSuperview()
          $0.bottom.equalTo(self.snp.top).offset(5)
        }
        
      case .leftTop:
        tipView.snp.makeConstraints {
          $0.leading.equalToSuperview().offset(32)
          $0.bottom.equalTo(self.snp.top).offset(5)
        }
        
      case .rightTop:
        tipView.snp.makeConstraints {
          $0.trailing.equalToSuperview().offset(-32)
          $0.bottom.equalTo(self.snp.top).offset(5)
        }
        
      case .centerBottom:
        tipView.snp.makeConstraints {
          $0.centerX.equalToSuperview()
          $0.bottom.equalToSuperview().offset(9)
        }
        
      case .leftBottom:
        tipView.snp.makeConstraints {
          $0.leading.equalToSuperview().offset(32)
          $0.bottom.equalToSuperview().offset(9)
        }
        
      case .rightBottom:
        tipView.snp.makeConstraints {
          $0.trailing.equalToSuperview().offset(-32)
          $0.bottom.equalToSuperview().offset(9)
        }
        
      default: break
    }
  }
}

// MARK: - Public Methods
public extension ToastView {
  func setConstraints(_ closure: @escaping (_ make: ConstraintMaker) -> Void) {
    self.toastViewConstraints = closure
  }
  
  func present(
    at view: UIView,
    duration: CGFloat = 3.0,
    completion: (() -> Void)? = nil
  ) {
    guard let constraint = toastViewConstraints else { return }
    workItem?.cancel()
    self.isRemoved = false
    view.addSubview(self)
    self.snp.makeConstraints(constraint)
    
    let workItem = DispatchWorkItem { [weak self] in
      self?.remove(completion)
    }

    self.workItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
  }
  
  func present(
    to viewController: UIViewController,
    duration: CGFloat = 3.0,
    completion: (() -> Void)? = nil
  ) {
    guard let view = viewController.view else { return }
    present(at: view, duration: duration, completion: completion)
  }
}

// MARK: - Private Methods
private extension ToastView {
  func setTipView(for posision: TipPosition) {
    switch posision {
      case .centerTop, .leftTop, .rightTop:
        tipView = TipView(tipDirection: .top)
      case .leftBottom, .centerBottom, .rightBottom:
        tipView = TipView(tipDirection: .bottom)
      default: break
    }
  }
  
  func setLabel(_ text: String) {
    label.attributedText = text.attributedString(
      font: .body2Bold,
      color: .photiWhite
    )
  }
  
  func setIconView(_ icon: UIImage) {
    iconView.contentMode = .scaleAspectFit
    iconView.image = icon
    iconView.tintColor = .gray200
  }
  
  func remove(_ completion: (() -> Void)? = nil) {
    guard !isRemoved else { return }
    
    self.isRemoved = true
    UIView.animate(withDuration: 0.4) {
      self.alpha = 0.0
    } completion: { _ in
      self.removeFromSuperview()
      completion?()
      self.alpha = 1.0
    }
  }
}
