//
//  SearchResultViewController.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class SearchResultViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let viewModel: SearchResultViewModel
  private let disposeBag = DisposeBag()
  private var segmentIndex: Int = 0
  
  // MARK: - UI Components
  private var segmentViewControllers = [UIViewController]()
  private let navigationBar = UIView()
  
  private let backButton: UIButton = {
    let button = UIButton()
    button.setImage(.chevronBackGray700, for: .normal)
    button.setImage(.chevronBackGray700, for: .highlighted)

    return button
  }()
  
  private let searchBar = PhotiSearchBar(placeholder: "챌린지, 해시태그를 검색해보세요")
  
  /// 검색어가 없을때, 나타나는 화면
  private let searchSuggestionView = UIView()
  private let recentSearchInputView = RecentSearchInputView()
  private let emptyRecentSearchInputLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "최근 검색어가 없어요.".attributedString(font: .body2, color: .gray400)
    
    return label
  }()
  
  /// 검색어가 있을때, 나타나는 화면
  private let searchResultView = UIView()
  private let segmentControl = CenterSegmentControl(items: ["챌린지 이름", "해시태그"])
  private let mainContentView = UIView()
  
  // MARK: - Initializers
  init(viewModel: SearchResultViewModel) {
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    searchBar.becomeFirstResponder()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      self?.hideTabBar(animated: true)
    }
  }
  
  // MARK: - UI Responder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension SearchResultViewController {
  func setupUI() {
    view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, searchSuggestionView, searchResultView)
    navigationBar.addSubviews(backButton, searchBar)
    searchSuggestionView.addSubviews(recentSearchInputView, emptyRecentSearchInputLabel)
    searchResultView.addSubviews(segmentControl, mainContentView)
  }
  
  func setConstraints() {
    setNavigationBarConstraints()
    setSearchSuggestionViewConstraints()
    setSearchResultViewConstraints()
  }
  
  func setNavigationBarConstraints() {
    navigationBar.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.trailing.leading.equalToSuperview()
      $0.height.equalTo(56)
    }
    
    backButton.snp.makeConstraints {
      $0.width.height.equalTo(24)
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(17)
    }
    
    searchBar.snp.makeConstraints {
      $0.leading.equalTo(backButton.snp.trailing).offset(14)
      $0.trailing.equalToSuperview().inset(24)
      $0.centerY.equalToSuperview()
    }
  }
  
  func setSearchSuggestionViewConstraints() {
    searchSuggestionView.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    recentSearchInputView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(24)
      $0.top.equalToSuperview().inset(25)
      $0.trailing.equalToSuperview()
    }
    
    emptyRecentSearchInputLabel.snp.makeConstraints {
      $0.center.equalTo(view)
    }
  }
  
  func setSearchResultViewConstraints() {
    searchResultView.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    segmentControl.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(48)
    }
    
    mainContentView.snp.makeConstraints {
      $0.leading.bottom.trailing.equalToSuperview()
      $0.top.equalTo(segmentControl.snp.bottom)
    }
  }
}

// MARK: - Bind Methods
private extension SearchResultViewController {
  func bind() {
    let didEnterSearchText = searchBar.rx.controlEvent(.editingDidEnd)
      .withLatestFrom(searchBar.rx.text)
      .compactMap { $0 }
      .filter { !$0.isEmpty }
    
    let input = SearchResultViewModel.Input(
      didTapBackButton: backButton.rx.tap.asSignal(),
      searchText: searchBar.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: ""),
      didEnterSearchText: didEnterSearchText.asSignal(onErrorJustReturn: ""),
      deleteAllRecentSearchInputs: recentSearchInputView.rx.deleteAllRecentSearchInputs,
      deleteRecentSearchInput: recentSearchInputView.rx.deleteRecentSearchInput
    )
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() {
    recentSearchInputView.rx.didTapRecentSearchInput
      .emit(with: self) { owner, searchInput in
        owner.searchBar.text = searchInput
        owner.searchBar.sendActions(for: .editingDidEnd)
      }
      .disposed(by: disposeBag)
    
    segmentControl.rx.selectedSegment
      .bind(with: self) { owner, index in
        owner.updateSegmentViewController(to: index)
      }
      .disposed(by: disposeBag)
  }
  
  func viewModelBind(for output: SearchResultViewModel.Output) {
    output.searchResultMode
      .drive(with: self) { owner, mode in
        switch mode {
          case .searchInputSuggestion(let suggestion):
            owner.configureSearchSuggestionView(suggestion)
            owner.searchSuggestionView.isHidden = false
            owner.searchResultView.isHidden = true
          case .searchResult:
            owner.searchSuggestionView.isHidden = true
            owner.searchResultView.isHidden = false
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - SearchResultPresentable
extension SearchResultViewController: SearchResultPresentable {
  func attachViewControllerables(_ viewControllerables: ViewControllerable...) {
    segmentViewControllers = viewControllerables.map(\.uiviewController)
    
    attachViewController(segmentIndex: segmentIndex)
  }
}

// MARK: - Private Methods
private extension SearchResultViewController {
  func updateSegmentViewController(to index: Int) {
    defer { segmentIndex = index }
    removeViewController(segmentIndex: segmentIndex)
    attachViewController(segmentIndex: index)
  }
  
  func removeViewController(segmentIndex: Int) {
    guard segmentViewControllers.count > segmentIndex else { return }
    
    let viewController = segmentViewControllers[segmentIndex]
    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
    viewController.didMove(toParent: nil)
  }
  
  func attachViewController(segmentIndex: Int) {
    guard segmentViewControllers.count > segmentIndex else { return }
    
    let viewController = segmentViewControllers[segmentIndex]
    viewController.willMove(toParent: self)
    addChild(viewController)
    viewController.didMove(toParent: self)
    mainContentView.addSubview(viewController.view)
    viewController.view.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  func configureSearchSuggestionView(_ suggestions: [String]) {
    emptyRecentSearchInputLabel.isHidden = !suggestions.isEmpty
    recentSearchInputView.isHidden = suggestions.isEmpty
    
    if !suggestions.isEmpty { recentSearchInputView.append(searchInputs: suggestions) }
  }
}
