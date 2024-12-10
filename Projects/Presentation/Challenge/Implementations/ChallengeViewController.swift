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
  private let viewModel: ChallengeViewModel
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    rigthItems: [.shareButton, .optionButton],
    displayMode: .white
  )
  private let titleView = ChallengeTitleView()
  private let segmentControl = PhotiSegmentControl(items: ["피드", "소개", "파티원"])
  
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
    view.addSubviews(titleView, navigationBar, segmentControl)
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
  }
}
