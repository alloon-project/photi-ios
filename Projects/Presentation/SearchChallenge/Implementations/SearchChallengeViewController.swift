//
//  SearchChallengeViewController.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class SearchChallengeViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: SearchChallengeViewModel
  private var segmentIndex: Int = 0
  
  // MARK: - UI Components
  private var segmentViewControllers = [UIViewController]()
  private let challengeOrganizeButton = FloatingButton(type: .primary, size: .xLarge)
  private let searchBar = PhotiSearchBar(placeholder: "챌린지, 해시태그를 검색해보세요")
  private let segmentControl = CenterSegmentControl(items: ["추천순", "최신순"])
  
  init(viewModel: SearchChallengeViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bind()
  }
}

// MARK: - SearchChallengePresentable
extension SearchChallengeViewController: SearchChallengePresentable {
  func attachViewControllerables(_ viewControllerables: ViewControllerable...) {
    segmentViewControllers = viewControllerables.map(\.uiviewController)
    
    attachViewController(segmentIndex: segmentIndex)
  }
  }

// MARK: - Private methods
private extension SearchChallengeViewController {
  func setupUI() {
    view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.view.addSubview(challengeOrganizeButton)
  }
  
  func setConstraints() {
    challengeOrganizeButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(24)
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(24)
      $0.width.height.equalTo(56)
    }
  }
}

// MARK: - Bind Methods
private extension SearchChallengeViewController {
  func bind() {
    let input = SearchChallengeViewModel.Input(
      didTapChallengeOrganizeButton: challengeOrganizeButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    bind(output: output)
  }
  
  func bind(output: SearchChallengeViewModel.Output) {}
}

// MARK: - Private Methods
private extension SearchChallengeViewController {
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
