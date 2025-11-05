//
//  ChallengeHashtagViewController.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ChallengeHashtagViewController: UIViewController, ViewControllerable {
  // MARK: - Variables
  private let mode: ChallengeOrganizeMode
  private let disposeBag = DisposeBag()
  private var cancellables: Set<AnyCancellable> = []
  private let viewModel: ChallengeHashtagViewModel
  
  private var hashtagsDataSource: [String] = [] {
    didSet { hashtagCollectionView.reloadData() }
  }
  private var selectedHashtags = BehaviorRelay<[String]>(value: [])
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let progressBar = LargeProgressBar(step: .four)
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "챌린지를 표현하는 해시태그를 정해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let addHashtagTextField = ButtonTextField(
    buttonText: "추가하기",
    placeholder: "해시태그",
    type: .helper,
    mode: .default
  )
  
  private let commentView = CommentView(.condition, text: "6자 이하", icon: .checkBlue)
  
  private let hashtagCollectionView = HashTagCollectionView(allignMent: .leading)
  
  private let nextButton = FilledRoundButton(
    type: .primary,
    size: .xLarge,
    text: "다음"
  )
  
  // MARK: - Initialziers
  init(
    mode: ChallengeOrganizeMode,
    viewModel: ChallengeHashtagViewModel
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
    
    setupUI()
    bind()
    hashtagCollectionView.registerCell(HashTagCell.self)
    hashtagCollectionView.delegate = self
    hashtagCollectionView.dataSource = self
  }
  
  // MARK: - UI Responder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension ChallengeHashtagViewController {
  func setupUI() {
    view.backgroundColor = .white
    
    setViewHierarchy()
    setConstraints()
    addHashtagTextField.commentViews = [commentView]
    
    if case .modify = mode {
      navigationBar.title = "챌린지 해시태그 수정"
      nextButton.title = "저장하기"
    }
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      progressBar,
      titleLabel,
      addHashtagTextField,
      hashtagCollectionView,
      nextButton
    )
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    if case .modify = mode {
      titleLabel.snp.makeConstraints {
        $0.top.equalTo(navigationBar.snp.bottom).offset(36)
        $0.leading.equalToSuperview().offset(24)
      }
    } else {
      progressBar.snp.makeConstraints {
        $0.top.equalTo(navigationBar.snp.bottom).offset(8)
        $0.leading.trailing.equalToSuperview().inset(24)
      }
      
      titleLabel.snp.makeConstraints {
        $0.top.equalTo(progressBar.snp.bottom).offset(48)
        $0.leading.equalToSuperview().offset(24)
      }
    }
    
    addHashtagTextField.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().inset(24)
    }
    
    hashtagCollectionView.snp.makeConstraints {
      $0.top.equalTo(addHashtagTextField.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(50)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension ChallengeHashtagViewController {
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
    
    let input = ChallengeHashtagViewModel.Input(
      didTapBackButton: backButtonEvent,
      enteredHashtag: addHashtagTextField.textField.rx.text.orEmpty,
      selectedHashtags: selectedHashtags.asDriver(),
      didTapNextButton: nextButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(for: output)
  }
  
  func viewBind() {
    addHashtagTextField.buttonTapPublisher
      .withLatestFrom(addHashtagTextField.textPublisher)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .sinkOnMain(with: self) { owner, hashTag in
        owner.hashtagsDataSource.append(hashTag)
        owner.selectedHashtags.accept(owner.hashtagsDataSource)
        owner.addHashtagTextField.text = ""
      }.store(in: &cancellables)
    
    selectedHashtags
      .filter { $0.count >= 3 }
      .bind(with: self) { owner, _ in
        owner.view.endEditing(true)
        owner.presentHashtagLimitToastView()
      }
      .disposed(by: disposeBag)
  }
  
  func bind(for output: ChallengeHashtagViewModel.Output) {
    output.isValidHashtag
      .drive(commentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.isEnableAddHashtagButton
      .drive(addHashtagTextField.rx.buttonIsEnabled)
      .disposed(by: disposeBag)
    
    output.isEnabledNextButton
      .drive(nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }
}

// MARK: - ChallengeHashtagPresentable
extension ChallengeHashtagViewController: ChallengeHashtagPresentable { }

// MARK: - Private Methods
private extension ChallengeHashtagViewController {
  func presentHashtagLimitToastView() {
    let toastText = "해시태그는 3개까지 등록 가능해요"
    let toastView = ToastView(tipPosition: .none, text: toastText, icon: .bulbWhite)
    toastView.setConstraints {
      $0.bottom.equalToSuperview().inset(64)
      $0.centerX.equalToSuperview()
    }
    
    toastView.present(to: self)
  }
}

// MARK: - UICollectionView Delegate
extension ChallengeHashtagViewController: UICollectionViewDelegate {}

// MARK: - UICollectionView DateSources
extension ChallengeHashtagViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    hashtagsDataSource.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(HashTagCell.self, for: indexPath)
    cell.configure(
      type: .icon(size: .large, type: .blue),
      text: hashtagsDataSource[indexPath.item]
    )
    
    cell.rx.didTapCloseButton
      .bind(with: self) { owner, _ in
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        owner.hashtagsDataSource.remove(at: indexPath.item)
        owner.selectedHashtags.accept(owner.hashtagsDataSource)
      }
      .disposed(by: disposeBag)
    
    return cell
  }
}
