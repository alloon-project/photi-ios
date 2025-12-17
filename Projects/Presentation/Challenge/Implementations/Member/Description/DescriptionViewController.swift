//
//  DescriptionViewController.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Coordinator
import RxCocoa
import RxSwift
import SnapKit
import CoreUI
import DesignSystem

final class DescriptionViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let viewModel: DescriptionViewModel
  private let disposeBag = DisposeBag()
  
  private let requestData = PublishRelay<Void>()
  
  // MARK: - UI Components
  private let mainContainerView = UIView()
  private let ruleDescriptionView = RuleDescriptionView()
  private let goalDescriptionView = DescriptionView(type: .goal)
  private let durationDescriptionView = DescriptionView(type: .duration)
  private let seperatorViewBetweenRuleAndGoal: UIView = {
    let view = UIView()
    view.backgroundColor = .gray100
    
    return view
  }()
  private let seperatorViewBetweenGoalAndDuration: UIView = {
    let view = UIView()
    view.backgroundColor = .gray100
    
    return view
  }()
  
  // MARK: - Initializers
  init(viewModel: DescriptionViewModel) {
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
    
    requestData.accept(())
  }
}

// MARK: - UI Methods
private extension DescriptionViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(mainContainerView)
    mainContainerView.addSubviews(
      ruleDescriptionView,
      goalDescriptionView,
      durationDescriptionView,
      seperatorViewBetweenRuleAndGoal,
      seperatorViewBetweenGoalAndDuration
    )
  }
  
  func setConstraints() {
    mainContainerView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(32)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview()
    }
    
    ruleDescriptionView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }
    
    seperatorViewBetweenRuleAndGoal.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(ruleDescriptionView.snp.bottom).offset(24)
    }
    
    goalDescriptionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(seperatorViewBetweenRuleAndGoal.snp.bottom).offset(32)
    }
    
    seperatorViewBetweenGoalAndDuration.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(goalDescriptionView.snp.bottom).offset(24)
    }
    
    durationDescriptionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(seperatorViewBetweenGoalAndDuration.snp.bottom).offset(32)
    }
  }
}

// MARK: - Bind Methods
private extension DescriptionViewController {
  func bind() {
    let input = DescriptionViewModel.Input(requestData: requestData.asSignal())
    let output = viewModel.transform(input: input)
    viewModelBind(for: output)
  }
  
  func viewModelBind(for output: DescriptionViewModel.Output) {
    output.rules
      .drive(ruleDescriptionView.rx.rules)
      .disposed(by: disposeBag)
    
    output.proveTime
      .drive(ruleDescriptionView.rx.proveTime)
      .disposed(by: disposeBag)
    
    output.goal
      .drive(goalDescriptionView.rx.content)
      .disposed(by: disposeBag)
    
    output.duration
      .drive(durationDescriptionView.rx.content)
      .disposed(by: disposeBag)
  }
}

// MARK: - DescriptionPresentable
extension DescriptionViewController: DescriptionPresentable { }
