//
//  LogInGuideViewController.swift
//  ChallengeImpl
//
//  Created by jung on 1/31/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Coordinator
import RxCocoa
import RxSwift
import SnapKit
import CoreUI
import DesignSystem

final class LogInGuideViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let viewModel: LogInGuideViewModel
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.attributedText = "로그인하시면\n챌린지에 참여할 수 있어요".attributedString(
      font: .heading2,
      color: .gray900,
      alignment: .center
    )
    return label
  }()
  private let imageView = UIImageView(image: .homeNoneMember)
  private let button = FilledRoundButton(type: .primary, size: .xLarge, text: "로그인하러 가볼까요?")

  // MARK: - Initializers
  init(viewModel: LogInGuideViewModel) {
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
private extension LogInGuideViewController {
  func setupUI() {
    view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, titleLabel, imageView, button)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(60)
      $0.centerX.equalToSuperview()
    }
    
    imageView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(407)
      $0.width.equalTo(375)
    }
    
    button.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(56)
      $0.centerX.equalToSuperview()
    }
  }
}

// MARK: - Bind Methods
private extension LogInGuideViewController {
  func bind() {
    let backButtonEvent: ControlEvent<Void> = {
      let events = Observable<Void>.create { [weak navigationBar] observer in
        guard let bar = navigationBar else { return Disposables.create() }
        let cancellable = bar.didTapBackButton
          .sink { observer.onNext(()) }
        return Disposables.create { cancellable.cancel() }
      }
      return ControlEvent(events: events)
    }()
    
    let input = LogInGuideViewModel.Input(
      didTapBackButton: backButtonEvent,
      didTapLogInButton: button.rx.tap
    )
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() { }
  
  func viewModelBind(for output: LogInGuideViewModel.Output) { }
}

// MARK: - LogInGuidePresentable
extension LogInGuideViewController: LogInGuidePresentable { }
