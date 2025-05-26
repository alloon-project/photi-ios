//
//  ChallengeHashtagViewController.swift
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

final class ChallengeHashtagViewController: UIViewController, ViewControllerable {
  // MARK: - Variables
  private let disposeBag = DisposeBag()
  private let viewModel: ChallengeHashtagViewModel
  
  private var hashtagsDataSource: [String] = [] {
    didSet {
      hashtagCollectionView.reloadData()
      selectedHashtags.accept(hashtagsDataSource)
    }
  }
  private var selectedHashtags = PublishRelay<[String]>()
  
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
  init(viewModel: ChallengeHashtagViewModel) {
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
    
    progressBar.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(progressBar.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
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
    let input = ChallengeHashtagViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      enteredHashtag: addHashtagTextField.rx.text,
      selectedHashtags: selectedHashtags.asObservable(),
      didTapNextButton: nextButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(for: output)
  }
  
  func viewBind() {
    addHashtagTextField.rx.didTapButton
      .withLatestFrom(addHashtagTextField.rx.text)
      .bind(with: self) { owner, newHashtag in
        if owner.hashtagsDataSource.count >= 3 {
          owner.presentHashtagLimitToastView()
        } else {
          owner.hashtagsDataSource.append(newHashtag)
          owner.addHashtagTextField.text = nil
        }
        owner.addHashtagTextField.dismissKeyboard()
      }.disposed(by: disposeBag)
    
    selectedHashtags.bind(with: self) { owner, tags in
      owner.addHashtagTextField.buttonIsEnabled = tags.count < 3
    }.disposed(by: disposeBag)
  }
  
  func bind(for output: ChallengeHashtagViewModel.Output) {
    output.isValidHashtag
      .drive(addHashtagTextField.rx.buttonIsEnabled)
      .disposed(by: disposeBag)
    
    output.isValidHashtag
      .drive(commentView.rx.isActivate)
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
    
    cell.onTapClose = { [weak self] in
      guard
        let self,
        collectionView.indexPath(for: cell) != nil
      else { return }
      
      hashtagsDataSource.remove(at: indexPath.item)
    }
    
    return cell
  }
}
