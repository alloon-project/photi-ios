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
  private let viewModel: SearchChallengeViewModel
  
  private let challengeOrganizeButton = {
    let button = FloatingButton(type: .primary, size: .xLarge)
    button.setImage(.plusWhite.resize(CGSize(width: 24, height: 24)), for: .normal)
    button.backgroundColor = .blue500
    return button
  }()
  
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
extension SearchChallengeViewController: SearchChallengePresentable { }

// MARK: - Private methods
private extension SearchChallengeViewController {
  func setupUI() {
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
