//
//  RecommendedChallengesViewController.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class RecommendedChallengesViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let viewModel: RecommendedChallengesViewModel
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  // MARK: - Initializers
  init(viewModel: RecommendedChallengesViewModel) {
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
    view.backgroundColor = .red
    setupUI()
  }
}

// MARK: - UI Methods
private extension RecommendedChallengesViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() { }
  
  func setConstraints() { }
}

// MARK: - Bind Methods
private extension RecommendedChallengesViewController {
  func bind() {
    let input = RecommendedChallengesViewModel.Input()
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() { }
  
  func viewModelBind(for output: RecommendedChallengesViewModel.Output) { }
}

// MARK: - RecommendedChallengesPresentable
extension RecommendedChallengesViewController: RecommendedChallengesPresentable { }
