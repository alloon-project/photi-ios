//
//  FeedsByDateViewController.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class FeedsByDateViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let viewModel: FeedsByDateViewModel
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  // MARK: - Initializers
  init(viewModel: FeedsByDateViewModel) {
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
private extension FeedsByDateViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() { }
  
  func setConstraints() { }
}

// MARK: - Bind Methods
private extension FeedsByDateViewController {
  func bind() {
    let input = FeedsByDateViewModel.Input()
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() { }
  
  func viewModelBind(for output: FeedsByDateViewModel.Output) { }
}

// MARK: - FeedsByDatePresentable
extension FeedsByDateViewController: FeedsByDatePresentable { }
