//
//  ChallengeNameViewController.swift
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
import Core
import DesignSystem

final class ChallengeNameViewController: UIViewController, ViewControllerable {
  private let mode: ChallengeOrganizeMode
  private let disposeBag = DisposeBag()
  private let viewModel: ChallengeNameViewModel
  private var isPublicRelay: BehaviorRelay<Bool> = BehaviorRelay(value: true)
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let progressBar = LargeProgressBar(step: .one)
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "챌린지 이름을 정해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let challengeNameTextField: LineTextField = LineTextField(
    placeholder: "이 챌린지의 이름은?",
    type: .count(16)
  )

  private let publicLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "전체공개".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let publicCommentBox = UIView()
  private let publicCommentImageView = {
    let imageView = UIImageView()
    imageView.image = .postitBlue
    return imageView
  }()
  
  private let publicCommentLabel = {
    let label = UILabel()
    label.attributedText = "다양한 사람들과 챌린지를 즐겨요".attributedString(font: .caption1, color: .blue400)
    
    return label
  }()
  
  private let privateComment: CommentView = {
    let commentView = CommentView(
      .condition,
      text: "친한 친구들과 챌린지를 즐겨요",
      icon: .peopleBlue,
      isActivate: true
    )
    commentView.isHidden = true
    return commentView
  }()
  
  private let publicSwitch = {
    let publicSwitch = UISwitch()
    publicSwitch.isOn = true
    publicSwitch.onTintColor = .blue400
    
    return publicSwitch
  }()
  
  private let nextButton = FilledRoundButton(
    type: .primary,
    size: .xLarge,
    text: "다음"
  )
  
  // MARK: - Initialziers
  init(
    mode: ChallengeOrganizeMode,
    viewModel: ChallengeNameViewModel
  ) {
    self.mode = mode
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cylces
  override func viewDidLoad() {
    super.viewDidLoad()
    publicSwitch.addTarget(self, action: #selector(toggleSwitch), for: .valueChanged)

    setupUI()
    bind()
  }
  
  // MARK: - UI Responder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension ChallengeNameViewController {
  func setupUI() {
    view.backgroundColor = .white
    challengeNameTextField.setKeyboardType(.default)
    setViewHierarchy()
    setConstraints()
    
    if case .modify = mode {
      navigationBar.title = "챌린지 이름 수정"
      nextButton.title = "저장하기"
    }
  }
  
  func setViewHierarchy() {
    if case .modify = mode {
      view.addSubviews(
        navigationBar,
        titleLabel,
        challengeNameTextField,
        nextButton
      )
    } else {
      view.addSubviews(
        navigationBar,
        progressBar,
        titleLabel,
        challengeNameTextField,
        publicLabel,
        publicCommentBox,
        privateComment,
        publicSwitch,
        nextButton
      )
      
      publicCommentBox.addSubviews(publicCommentImageView, publicCommentLabel)
    }
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    if case .modify = mode {
      setModifyModeConstraints()
    } else {
      setOrganizeModeConstraints()
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
  
  func setModifyModeConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(36)
      $0.leading.equalToSuperview().offset(24)
    }
    
    challengeNameTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
  }
  
  func setOrganizeModeConstraints() {
    progressBar.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(progressBar.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    challengeNameTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    publicLabel.snp.makeConstraints {
      $0.top.equalTo(challengeNameTextField.snp.bottom).offset(53)
      $0.leading.equalTo(challengeNameTextField)
    }
    
    publicCommentBox.snp.makeConstraints {
      $0.leading.equalTo(publicLabel)
      $0.top.equalTo(publicLabel.snp.bottom).offset(16)
    }
    
    publicCommentImageView.snp.makeConstraints {
      $0.leading.equalTo(publicCommentBox)
      $0.top.bottom.equalToSuperview()
      $0.width.height.equalTo(12)
    }
    
    publicCommentLabel.snp.makeConstraints {
      $0.leading.equalTo(publicCommentImageView.snp.trailing).offset(6)
      $0.top.bottom.equalToSuperview()
    }
    
    privateComment.snp.makeConstraints {
      $0.leading.equalTo(publicLabel)
      $0.top.equalTo(publicLabel.snp.bottom).offset(16)
    }
    
    publicSwitch.snp.makeConstraints {
      $0.top.equalTo(publicLabel).offset(4)
      $0.trailing.equalToSuperview().inset(24)
    }
  }
}

// MARK: - Bind Methods
private extension ChallengeNameViewController {
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
    
    let input = ChallengeNameViewModel.Input(
      didTapBackButton: backButtonEvent,
      challengeName: challengeNameTextField.textField.rx.text.orEmpty,
      isPublicChallenge: isPublicRelay.asObservable(),
      didTapNextButton: nextButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
    viewBind()
  }
  
  func bind(for output: ChallengeNameViewModel.Output) { }
  
  func viewBind() {
    challengeNameTextField.textField.rx.text.orEmpty
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .map { !$0.isEmpty }
      .bind(to: nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
      
    isPublicRelay.asObservable()
      .bind(with: self) { owner, isPublic in
        owner.publicCommentBox.isHidden = !isPublic
        owner.privateComment.isHidden = isPublic
      }.disposed(by: disposeBag)
  }
}

// MARK: - ChallengeNamePresentable
extension ChallengeNameViewController: ChallengeNamePresentable {
  func setChallengeName(_ name: String) {
    self.challengeNameTextField.text = name
  }
}

// MARK: - Private Methods
private extension ChallengeNameViewController {
  @objc
  func toggleSwitch() {
    isPublicRelay.accept(publicSwitch.isOn)
  }
}
