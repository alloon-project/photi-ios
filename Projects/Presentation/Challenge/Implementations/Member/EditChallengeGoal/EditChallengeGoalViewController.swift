//
//  EditChallengeGoalViewController.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class EditChallengeGoalViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let viewModel: EditChallengeGoalViewModel
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  // MARK: - Initializers
  init(viewModel: EditChallengeGoalViewModel) {
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
private extension EditChallengeGoalViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() { }
  
  func setConstraints() { }
}

// MARK: - Bind Methods
private extension EditChallengeGoalViewController {
  func bind() {
    let input = EditChallengeGoalViewModel.Input()
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() { }
  
  func viewModelBind(for output: EditChallengeGoalViewModel.Output) { }
}

// MARK: - EditChallengeGoalPresentable
extension EditChallengeGoalViewController: EditChallengeGoalPresentable { }
