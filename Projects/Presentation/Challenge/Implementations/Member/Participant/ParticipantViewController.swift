//
//  ParticipantViewController.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ParticipantViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let viewModel: ParticipantViewModel
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  // MARK: - Initializers
  init(viewModel: ParticipantViewModel) {
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
private extension ParticipantViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() { }
  
  func setConstraints() { }
}

// MARK: - Bind Methods
private extension ParticipantViewController {
  func bind() {
    let input = ParticipantViewModel.Input()
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() { }
  
  func viewModelBind(for output: ParticipantViewModel.Output) { }
}

// MARK: - ParticipantPresentable
extension ParticipantViewController: ParticipantPresentable { }
