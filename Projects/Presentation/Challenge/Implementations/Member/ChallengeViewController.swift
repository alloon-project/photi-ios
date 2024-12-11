//
//  ChallengeViewController.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Core
import DesignSystem

final class ChallengeViewController: UIViewController {
  // MARK: - Properties
  private let viewModel: ChallengeViewModel
  private let disposeBag = DisposeBag()
  private var segmentIndex: Int = 0
  
  // MARK: - UI Components
  private var segmentViewControllers = [UIViewController]()
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    rigthItems: [.shareButton, .optionButton],
    displayMode: .white
  )
  private let titleView = ChallengeTitleView()
  private let segmentControl = PhotiSegmentControl(items: ["피드", "소개", "파티원"])
  private let mainContentScrollView = UIScrollView()
  private let mainContentView = UIView()
  
  // MARK: - Initializers
  init(viewModel: ChallengeViewModel) {
    self.viewModel = viewModel
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
  }
}

// MARK: - UI Methods
private extension ChallengeViewController {
  func setupUI() {
    setViewHierarhcy()
    setConstraints()
  }
  
  func setViewHierarhcy() {
    view.addSubviews(titleView, navigationBar, segmentControl, mainContentScrollView)
    mainContentScrollView.addSubview(mainContentView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    titleView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(300)
    }
    
    segmentControl.snp.makeConstraints {
      $0.bottom.equalTo(titleView)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(38)
    }
    
    mainContentScrollView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.top.equalTo(segmentControl.snp.bottom)
    }

    mainContentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
    }
  }
}

// MARK: - Bind
private extension ChallengeViewController {
  func bind() { }
}

// MARK: - ChallengePresentable
extension ChallengeViewController: ChallengePresentable {
  func attachViewControllers(_ viewControllers: UIViewController...) {
    segmentViewControllers = viewControllers

    attachViewController(segmentIndex: segmentIndex)
  }
}

// MARK: - Private Methods
// TODO: - 네이밍 수정
private extension ChallengeViewController {
  func updateSegmentViewController(to index: Int) {
    defer { segmentIndex = index }
    removeViewController(segmentIndex: segmentIndex)
    attachViewController(segmentIndex: index)
  }
  
  func removeViewController(segmentIndex: Int) {
    guard segmentViewControllers.count > segmentIndex else { return }
    
    let viewController = segmentViewControllers[segmentIndex]
    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
    viewController.didMove(toParent: nil)
  }
  
  func attachViewController(segmentIndex: Int) {
    guard segmentViewControllers.count > segmentIndex else { return }
    
    let viewController = segmentViewControllers[segmentIndex]
    viewController.willMove(toParent: self)
    addChild(viewController)
    viewController.didMove(toParent: self)
    mainContentView.addSubview(viewController.view)
    viewController.view.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
