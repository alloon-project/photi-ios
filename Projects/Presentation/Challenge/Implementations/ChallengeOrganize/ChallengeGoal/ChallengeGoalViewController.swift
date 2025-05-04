//
//  ChallengeGoalViewController.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ChallengeGoalViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: ChallengeGoalViewModel
  private let proveTimeRelay = PublishRelay<String>()
  private let endDateRelay = PublishRelay<Date>()
  private var selectedHour: Int = 13
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let progressBar = LargeProgressBar(step: .two)
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "챌린지의 목표는 무엇인가요?".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let challengeGoalTextView = LineTextView(
    placeholder: "이루고자 하는 목표를 알려주세요!",
    type: .count(120)
  )

  private let setProveTimeLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "하루 인증 시간을 정해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let downImageView = UIImageView(image: .chevronDownGray400)

  private let proveTimeTextField: LineTextField = {
    let textField = LineTextField(placeholder: "00:00", type: .default)
    
    return textField
  }()
  
  private let proveComment = CommentView(
    .condition,
    text: "매일 이시간에 인증 사진을 올려요",
    icon: .timeGray400,
    isActivate: false
  )
  
  private let setEndDateLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "챌린지 종료 날짜를 정해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  private let dateTextField = DateTextField(startDate: Date(), type: .default)
  
  private let nextButton =  {
    let button = FilledRoundButton(
      type: .primary,
      size: .xLarge,
      text: "다음"
    )
    button.isEnabled = false
    
    return button
  }()
  
  // MARK: - Initialziers
  init(viewModel: ChallengeGoalViewModel) {
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
private extension ChallengeGoalViewController {
  func setupUI() {
    proveTimeTextField.textField.setRightView(
      downImageView,
      size: CGSize(width: 24.0, height: 24.0),
      leftPdding: 4,
      rightPadding: 16
    )
    proveTimeTextField.textField.delegate = self
    dateTextField.delegate = self
    view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      progressBar,
      titleLabel,
      challengeGoalTextView,
      setProveTimeLabel,
      proveTimeTextField,
      setEndDateLabel,
      dateTextField,
      nextButton
    )
    
    proveTimeTextField.commentViews = [proveComment]
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    progressBar.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(progressBar.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    challengeGoalTextView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    setProveTimeLabel.snp.makeConstraints {
      $0.top.equalTo(challengeGoalTextView.snp.bottom).offset(51)
      $0.leading.equalTo(challengeGoalTextView)
    }
    
    proveTimeTextField.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(setProveTimeLabel.snp.bottom).offset(16)
    }
    
    setEndDateLabel.snp.makeConstraints {
      $0.leading.equalTo(proveTimeTextField)
      $0.top.equalTo(proveTimeTextField.snp.bottom).offset(16)
    }
    
    dateTextField.snp.makeConstraints {
      $0.leading.equalTo(setEndDateLabel)
      $0.trailing.equalTo(challengeGoalTextView)
      $0.top.equalTo(setEndDateLabel.snp.bottom).offset(16)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension ChallengeGoalViewController {
  func bind() {
    let input = ChallengeGoalViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      challengeGoal: challengeGoalTextView.rx.text,
      proveTime: proveTimeRelay.asObservable(),
      date: endDateRelay.asObservable(),
      didTapNextButton: nextButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
    
    viewBind()
  }
  
  func bind(for output: ChallengeGoalViewModel.Output) {
    output.isEnabledNextButton
      .drive(with: self) { owner, isEnabled in
        owner.nextButton.isEnabled = isEnabled
      }.disposed(by: disposeBag)
  }
  
  func viewBind() {
    downImageView.rx.tapGesture()
      .when(.recognized)
      .bind(with: self) { owner, _ in
        owner.showTimePickerBottomSheet()
      }.disposed(by: disposeBag)
    
    dateTextField.rx.didTapButton
      .bind(with: self) { owner, _ in
        owner.showCalendar()
      }.disposed(by: disposeBag)
  }
}

// MARK: - ChallengeGoalPresentable
extension ChallengeGoalViewController: ChallengeGoalPresentable { }

// MARK: - Private Methods
private extension ChallengeGoalViewController {
  func showTimePickerBottomSheet() {
    let timePicker = TimePickerBottomSheet(
      selectedHour: selectedHour,
      buttonText: "인증시간 정하기"
    )
    timePicker.delegate = self
    timePicker.present(to: self, animated: true)
  }
  
  func showCalendar() {
    let calendar = DatePickerBottomSheetViewController(startDate: Date())
    calendar.buttonText = "종료일 고르기"
    calendar.delegate = self
    calendar.present(to: self, animated: true)
  }
}

extension ChallengeGoalViewController: TimePickerBottomSheetDelegate {
  func didSelect(hour: Int) {
    guard let timeString = hour.hourToTimeString() else { return }
    proveTimeTextField.text = timeString
    proveTimeRelay.accept(timeString)
    proveComment.isActivate = true
    selectedHour = hour
  }
}

extension ChallengeGoalViewController: DatePickerBottomSheetDelegate {
  func didSelect(date: Date) {
    endDateRelay.accept(date)
    dateTextField.endDate = date
  }
}

extension ChallengeGoalViewController: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      return false
  }
}
