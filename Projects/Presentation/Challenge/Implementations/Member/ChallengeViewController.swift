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

final class ChallengeViewController: UIViewController, ViewControllable {
  enum Constants {
    static let navigationHeight: CGFloat = 56
    static let titleViewHeight: CGFloat = 300
    static let mainViewTopOffset: CGFloat = titleViewHeight - segmentControlHeight
    static let segmentControlHeight: CGFloat = 38
  }
  
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
  private let mainView = UIView()
  private let mainContentView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
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
    bind()
  }
}

// MARK: - UI Methods
private extension ChallengeViewController {
  func setupUI() {
    setViewHierarhcy()
    setConstraints()
  }
  
  func setViewHierarhcy() {
    view.addSubviews(titleView, navigationBar, mainView)
    mainView.addSubviews(segmentControl, mainContentView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(Constants.navigationHeight)
    }
    
    titleView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(Constants.titleViewHeight)
    }
    
    mainView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(Constants.mainViewTopOffset)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    segmentControl.snp.makeConstraints {
      $0.leading.trailing.top.equalToSuperview()
      $0.height.equalTo(Constants.segmentControlHeight)
    }
    
    mainContentView.snp.makeConstraints {
      $0.top.equalTo(segmentControl.snp.bottom)
      $0.bottom.trailing.leading.equalToSuperview()
    }
  }
}

// MARK: - Bind
private extension ChallengeViewController {
  func bind() { }
}

// MARK: - ChallengePresentable
extension ChallengeViewController: ChallengePresentable {  
  func attachViewControllerables(_ viewControllerables: ViewControllable...) {
    segmentViewControllers = viewControllerables.map(\.uiviewController)

    attachViewController(segmentIndex: segmentIndex)
  }
  
  func didChangeContentOffsetAtMainContainer(_ offset: Double) {
    let minOffset = navigationBar.frame.maxY - 5
    let maxOffset = Constants.mainViewTopOffset
    
    let offset = offset.bound(lower: minOffset, upper: maxOffset)
    let mainContainerOffset = minOffset + maxOffset - offset

    mainView.snp.updateConstraints {
      $0.top.equalToSuperview().offset(mainContainerOffset)
    }
  }
}

// MARK: - Private Methods
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
