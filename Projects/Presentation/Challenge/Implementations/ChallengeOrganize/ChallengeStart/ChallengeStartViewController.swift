//
//  ChallengeStartViewController.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Coordinator
import RxCocoa
import RxSwift
import SnapKit
import CoreUI
import DesignSystem

final class ChallengeStartViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: ChallengeStartViewModel
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    displayMode: .dark
  )
  
  private let announceLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.attributedText = "개최하고 싶은\n챌린지가 있나요?".attributedString(
      font: .heading2,
      color: .gray900
    )
    label.textAlignment = .center
    
    return label
  }()
  
  private let startImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .challengeOrganizeMain
    
    return imageView
  }()
  
  private let firstAnnounceComment = CommentView(
    .condition,
    text: "파티장이 되어보세요",
    icon: .rocketBlue,
    isActivate: true
  )
  
  private let secondAnnounceComment = CommentView(
    .condition,
    text: "평균 5~10분이 소요돼요",
    icon: .timeBlue,
    isActivate: true
  )
  
  private let startButton = FilledRoundButton(
    type: .primary,
    size: .xLarge,
    text: "가보자구요!",
    mode: .default
  )
  
  // MARK: - Initiazliers
  init(viewModel: ChallengeStartViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    bind()
  }
  
  // MARK: - UIResponder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension ChallengeStartViewController {
  func setupUI() {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      startImageView,
      announceLabel,
      firstAnnounceComment,
      secondAnnounceComment,
      startButton
    )
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    announceLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.top.equalTo(navigationBar.snp.bottom).offset(40)
    }
  
    startImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(250)
    }
    
    startButton.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.bottom.equalToSuperview().offset(-56)
    }
    
    secondAnnounceComment.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(startButton.snp.top).inset(-32)
    }
    
    firstAnnounceComment.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(secondAnnounceComment.snp.top).inset(-20)
    }
  }
}

// MARK: - Bind Method
private extension ChallengeStartViewController {
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
    
    let input = ChallengeStartViewModel.Input(
      didTapBackButton: backButtonEvent,
      didTapStartButton: startButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
  }
}

// MARK: - ChallengeStartPresentable
extension ChallengeStartViewController: ChallengeStartPresentable { }
