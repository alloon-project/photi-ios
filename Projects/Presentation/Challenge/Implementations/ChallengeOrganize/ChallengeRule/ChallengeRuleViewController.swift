//
//  ChallengeRuleViewController.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Coordinator
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

struct Rule {
  let title: String
  var isSelected: Bool
}

final class ChallengeRuleViewController: UIViewController, ViewControllerable {
  // MARK: Variables
  private let mode: ChallengeOrganizeMode
  private let disposeBag = DisposeBag()
  private let viewModel: ChallengeRuleViewModel
  private var defaultRules: [Rule] = [
    Rule(title: "일주일 3회 이상 인증하기", isSelected: false),
    Rule(title: "매일 챌린지 참여하기", isSelected: false),
    Rule(title: "타인을 비방하지 말기", isSelected: false),
    Rule(title: "챌린지와 관련된 사진 올리기", isSelected: false),
    Rule(title: "팀원 인증글에 하트 누르기", isSelected: false),
    Rule(title: "사적인 질문하지 않기", isSelected: false)
  ]
  
  private var additionalRules: [Rule] = [
    Rule(title: "+", isSelected: false)
  ] {
    didSet {
      ruleCollectionView.reloadData()
    }
  }
  private var selectedRules: [String] = [] {
    didSet {
      selectedRulesRelay.accept(selectedRules)
    }
  }
  private let selectedRulesRelay = PublishRelay<[String]>()
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let progressBar = LargeProgressBar(step: .four)
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "인증 룰을 정해볼까요?".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let ruleCollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 8
    let cellWidth = (UIScreen.main.bounds.width - 8 - 24 * 2) / 2
    layout.itemSize = .init(width: cellWidth, height: 57)
    layout.sectionInset = .init(top: 16, left: 0, bottom: 16, right: 0)
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.registerHeader(ChallengeRuleHeaderView.self)
    collectionView.registerCell(ChallengeRuleCell.self)
    
    return collectionView
  }()
  private let bottomSheet = TextFieldBottomSheetViewController(
    textFieldType: .count(30),
    title: "새로운 룰 만들기",
    button: "추가하기",
    placeholder: "어떤 룰을 정해볼까요?"
  )
  private let nextButton = FilledRoundButton(
    type: .primary,
    size: .xLarge,
    text: "다음"
  )
  
  // MARK: - Initialziers
  init(
    mode: ChallengeOrganizeMode,
    viewModel: ChallengeRuleViewModel
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
    
    ruleCollectionView.delegate = self
    ruleCollectionView.dataSource = self
    bottomSheet.delegate = self
  }
  
  // MARK: - UI Responder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension ChallengeRuleViewController {
  func setupUI() {
    view.backgroundColor = .white
    
    setViewHierarchy()
    setConstraints()
    
    if case .modify = mode {
      navigationBar.title = "챌린지 인증 룰 수정"
      nextButton.title = "저장하기"
    }
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      progressBar,
      titleLabel,
      ruleCollectionView,
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
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
    
    ruleCollectionView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().inset(24)
      $0.bottom.equalTo(nextButton.snp.top).inset(24)
    }
  }
}

// MARK: - Bind Methods
private extension ChallengeRuleViewController {
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
    
    let input = ChallengeRuleViewModel.Input(
      didTapBackButton: backButtonEvent,
      challengeRules: selectedRulesRelay.asSignal(),
      didTapNextButton: nextButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: ChallengeRuleViewModel.Output) {
    output.isRuleSelected
      .drive(nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }
}

// MARK: - ChallengeRulePresentable
extension ChallengeRuleViewController: ChallengeRulePresentable {
  func setChallengeRule(rules: [String]) {
    var givenRules = rules
    for (index, rule) in defaultRules.enumerated() where rules.contains(rule.title) {
      defaultRules[index].isSelected = true
      givenRules.removeAll(where: { $0 == rule.title })
    }
    
    givenRules.forEach {
      additionalRules.insert(Rule(title: $0, isSelected: true), at: 0)
    }
    
    selectedRules = rules
  }
}

// MARK: - Private Methods
private extension ChallengeRuleViewController {
  func countSelectedRows() -> Int {
    let count = (defaultRules.filter { $0.isSelected }.count)
    + (additionalRules.filter { $0.isSelected }.count)
    
    return count
  }
  
  func presentRuleLimitToastView() {
    let toastText = "인증 룰은 5개까지 등록 가능해요"
    let toastView = ToastView(tipPosition: .none, text: toastText, icon: .bulbWhite)
    toastView.setConstraints {
      $0.bottom.equalToSuperview().inset(64)
      $0.centerX.equalToSuperview()
    }
    
    toastView.present(to: self)
  }
  
  func appendOrRemoveRule(rule: String, isSelected: Bool) {
    if isSelected {
      selectedRules.append(rule)
    } else {
      selectedRules = selectedRules.filter { !$0.contain(rule) }
    }
  }
  
  private func toggleRule(at indexPath: IndexPath) {
    guard indexPath.section < 2 else { return }
    
    var ruleList = (indexPath.section == 0) ? defaultRules : additionalRules
    var rule = ruleList[indexPath.item]
    
    if countSelectedRows() == 5 && !rule.isSelected {
      presentRuleLimitToastView()
      return
    }
    
    rule.isSelected.toggle()
    ruleList[indexPath.item] = rule
    
    // 반영
    if indexPath.section == 0 {
      defaultRules = ruleList
    } else {
      additionalRules = ruleList
    }
    
    appendOrRemoveRule(rule: rule.title, isSelected: rule.isSelected)
    ruleCollectionView.reloadItems(at: [indexPath])
  }
}

// MARK: - UICollectionview Delegate
extension ChallengeRuleViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // 추가 버튼 누를경우 동작
    if indexPath == IndexPath(item: additionalRules.count - 1, section: 1) {
      if additionalRules.count >= 6 {
        presentRuleLimitToastView()
        return
      }
      
      bottomSheet.present(to: self, animated: true)
      return
    }
    
    toggleRule(at: indexPath)
  }
}

// MARK: - UICollectionView DataSource
extension ChallengeRuleViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    2
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionHeader else {
      return UICollectionReusableView()
    }
    
    let header = collectionView.dequeueHeader(ChallengeRuleHeaderView.self, for: indexPath)
    
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return defaultRules.count
    } else {
      return additionalRules.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(ChallengeRuleCell.self, for: indexPath)
    
    if indexPath.section == 0 {
      let data = defaultRules[indexPath.item]
      cell.configure(with: data.title, isSelected: data.isSelected, isDefault: true)
    } else if indexPath.section == 1 {
      let data = additionalRules[indexPath.item]
      cell.configure(with: data.title, isSelected: data.isSelected, isDefault: false)
    }
    
    cell.onTapClose = { [weak self] in
      guard
        let self,
        collectionView.indexPath(for: cell) != nil
      else { return }
      
      if let selectedRulesIndex = selectedRules.firstIndex(of: additionalRules[indexPath.item].title) {
        selectedRules.remove(at: selectedRulesIndex)
      }
      additionalRules.remove(at: indexPath.item)
    }
    return cell
  }
}

// MARK: - UICollectionView Delegate
extension ChallengeRuleViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
    // section 0은 숨기고, section 1은 1 높이 헤더
    return section == 0 ? .zero : CGSize(width: collectionView.bounds.width, height: 1)
  }
}

// MARK: - TextFieldBottomSheet Delegate
extension ChallengeRuleViewController: TextFieldBottomSheetDelegate {
  func didTapCloseButton() {
    bottomSheet.textField.text = nil
  }
  
  func didTapConfirmButton(_ text: String) {
    bottomSheet.textField.text = nil
    let newRule = Rule(title: text.trimmingCharacters(in: .whitespacesAndNewlines), isSelected: false)
    let beforeCount = additionalRules.count - 1
    additionalRules.insert(newRule, at: beforeCount)
  }
}
