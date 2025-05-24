//
//  SearchChallengeViewController.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
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
  private let mainContentView = UIView()
  
  // MARK: - Initializers
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
    view.addSubviews(
      searchBar,
      segmentControl,
      mainContentView,
      challengeOrganizeButton
    )
  }
  
  func setConstraints() {
    let tabBarMinY = tabBarController?.tabBar.frame.minY ?? 0
    let tabBarHeight = view.frame.height - tabBarMinY
    searchBar.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    segmentControl.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(searchBar.snp.bottom).offset(6)
      $0.height.equalTo(48)
    }
    
    mainContentView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(segmentControl.snp.bottom)
      $0.bottom.equalToSuperview().inset(tabBarHeight)
    }
    
    challengeOrganizeButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(tabBarHeight + 24)
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
    viewBind()
  }
  
  func viewBind() {
    segmentControl.rx.selectedSegment
      .bind(with: self) { owner, index in
        owner.updateSegmentViewController(to: index)
      }
      .disposed(by: disposeBag)
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
