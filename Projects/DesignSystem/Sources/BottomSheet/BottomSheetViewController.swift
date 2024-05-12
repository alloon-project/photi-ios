//
//  BottomSheetViewController.swift
//  DesignSystem
//
//  Created by jung on 5/11/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxRelay
import SnapKit
import Core

open class BottomSheetViewController: UIViewController {
  /// 외부화면을 터치하거나,  swip down 제스쳐를 통해 종료한 경우 이벤트가 방출됩니다.
  public let didDismiss = PublishRelay<Void>()
  
  // MARK: - Constants
  /// BottomSheet의 최대 height를 정의합니다.
  /// screen.height - minTopSpacing
  private var minTopSpacing: CGFloat = 200
  
  private var presentAnimate: Bool = true
  
  // MARK: - UI Components
  private let mainContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 20
    view.clipsToBounds = true
    
    return view
  }()
  
  private let dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.2)
    return view
  }()
  
  /// 내부 Content가 들어있는 View입니다.
  open var contentView = UIView()
  
  // MARK: - View Life Cycles
  open override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupGestures()
  }
  
  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if presentAnimate {
      animatePresent()
    }
  }
  
  // MARK: - Present Method
  open func present(
    to viewController: UIViewController,
    animated: Bool,
    completion: (() -> Void)? = nil
  ) {
    modalPresentationStyle = .overFullScreen
    self.presentAnimate = animated
    viewController.present(self, animated: false, completion: completion)
  }
}

// MARK: - UI Methods
private extension BottomSheetViewController {
  func setupUI() {
    view.backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(dimmedView, mainContainerView)
    mainContainerView.addSubviews(contentView)
  }
  
  func setConstraints() {
    dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }
    
    mainContainerView.snp.makeConstraints { make in
      make.top.greaterThanOrEqualToSuperview().offset(minTopSpacing)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
}

// MARK: - Private Methods
private extension BottomSheetViewController {
  func setupGestures() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDimmedView))
    dimmedView.addGestureRecognizer(tapGesture)
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanMainContainerView))
    mainContainerView.addGestureRecognizer(panGesture)
  }
  
  @objc func didTapDimmedView() {
    dismissBottomSheet()
    didDismiss.accept(())
  }
  
  @objc func didPanMainContainerView(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: view)
    let isDraggingDown = translation.y > 0
    guard isDraggingDown else { return }
    
    let pannedHeight = translation.y
    let beforePannedY = self.view.frame.height - self.mainContainerView.frame.height
    
    switch gesture.state {
      case .changed:
        self.mainContainerView.frame.origin.y = beforePannedY + pannedHeight
        
      case .ended:
        // 절반 이상 내렸을 때, Dismiss
        let shouldDismiss = pannedHeight > self.mainContainerView.frame.height / 2
        if shouldDismiss {
          dismissBottomSheet()
          didDismiss.accept(())
        } else {
          self.mainContainerView.frame.origin.y = beforePannedY
        }
        
      default: break
    }
  }
  
  func animatePresent() {
    let beforeY = self.view.frame.height - self.mainContainerView.frame.height
    
    mainContainerView.frame.origin.y = self.view.frame.height
    
    UIView.animate(withDuration: 0.2) {
      self.mainContainerView.frame.origin.y = beforeY
      self.view.layoutIfNeeded()
    }
  }
}

// MARK: - Public Methods
public extension BottomSheetViewController {
  func dismissBottomSheet() {
    UIView.animate(withDuration: 0.3) {
      self.dimmedView.alpha = 0.7
      self.mainContainerView.frame.origin.y = self.view.frame.height
    } completion: { _ in
      self.dismiss(animated: false)
    }
  }
}
