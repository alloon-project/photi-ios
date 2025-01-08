//
//  PopOverViewController.swift
//  DesignSystem
//
//  Created by jung on 10/10/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

open class PopOverViewController: UIViewController {
  // MARK: - Properties
  private var presentAnimate: Bool = true

  // MARK: - UI Components
  public let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 16
    view.clipsToBounds = true
    
    return view
  }()
  
  private let dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4)

    return view
  }()
  
  // MARK: - Life Cycles
  open override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.containerView.isHidden = true
  }
  
  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if presentAnimate {
      animatePresent()
    }
  }
  
  // MARK: - Present Method
  /// `to`로 지정된 ViewController 위로 BottomSheet를 Display 합니다.
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
private extension PopOverViewController {
  func setupUI() {
    view.backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(dimmedView, containerView)
  }
  
  func setConstraints() {
    dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }
    
    containerView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}

// MARK: - Public Methods
public extension PopOverViewController {
  func dismissPopOver() {
    UIView.animate(withDuration: 0.2) {
      self.dimmedView.alpha = 0.7
      self.containerView.frame.origin.y = self.view.frame.height
    } completion: { _ in
      self.dismiss(animated: false)
    }
  }
}

// MARK: - Private Methods
private extension PopOverViewController {
  func animatePresent() {
    let beforeY = containerView.frame.origin.y
    
    containerView.frame.origin.y = self.view.frame.height
    containerView.isHidden = false
    UIView.animate(withDuration: 0.2) {
      self.containerView.frame.origin.y = beforeY
      self.view.layoutIfNeeded()
    }
  }
}
