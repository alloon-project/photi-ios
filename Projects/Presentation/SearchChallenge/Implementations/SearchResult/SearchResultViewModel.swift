//
//  SearchResultViewModel.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import UseCase

protocol SearchResultCoordinatable: AnyObject {
  func didTapBackButton()
}

protocol SearchResultViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: SearchResultCoordinatable? { get set }
}

enum SearchResultMode {
  case searchInputSuggestion(recent: [String])
  case searchResult
}

final class SearchResultViewModel: SearchResultViewModelType {
  typealias SearchMode = SearchResultViewController.SearchMode
  
  weak var coordinator: SearchResultCoordinatable?
  let titleSearchInput: Driver<String>
  let hashTagSearchInput: Driver<String>
  
  private let titleSearchInputRelay = BehaviorRelay(value: "")
  private let hashTagSearchInputRelay = BehaviorRelay(value: "")
  private let disposeBag = DisposeBag()
  private let useCase: SearchUseCase
  
  private let searchResultModeRelay = BehaviorRelay<SearchResultMode>(value: .searchInputSuggestion(recent: []))
  private var searchMode = SearchMode.title

  // MARK: - Input
  struct Input {
    let viewDidLoad: Signal<Void>
    let didTapBackButton: Signal<Void>
    let searchText: Signal<String>
    let deleteAllRecentSearchInputs: Signal<Void>
    let deleteRecentSearchInput: Signal<String>
    let searchMode: Driver<(mode: SearchMode, input: String)>
  }
  
  // MARK: - Output
  struct Output {
    let searchResultMode: Driver<SearchResultMode>
  }
  
  // MARK: - Initializers
  init(useCase: SearchUseCase) {
    self.useCase = useCase
    titleSearchInput = titleSearchInputRelay.asDriver()
    hashTagSearchInput = hashTagSearchInputRelay.asDriver()
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .emit(with: self) { owner, _ in
        owner.updateSearchResultMode("")
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.searchText
      .emit(with: self) { owner, text in
        owner.enterSearchInput(text)
        owner.updateSearchResultMode(text)
      }
      .disposed(by: disposeBag)

    input.deleteAllRecentSearchInputs
      .emit(with: self) { owner, _ in
        owner.deleteAllRecentSearchInputs()
      }
      .disposed(by: disposeBag)
    
    input.searchMode
      .drive(with: self) { owner, search in
        owner.searchMode = search.mode
        owner.enterSearchInput(search.input)
      }
      .disposed(by: disposeBag)
    
    input.deleteRecentSearchInput
      .emit(with: self) { owner, input in
        owner.deleteRecentSearchInput(input)
      }
      .disposed(by: disposeBag)

    return Output(searchResultMode: searchResultModeRelay.asDriver())
  }
}

// MARK: - Private Methods
private extension SearchResultViewModel {
  func updateSearchResultMode(_ text: String) {
    guard text.isEmpty else { return searchResultModeRelay.accept(.searchResult) }
    let input = useCase.searchHistory()
    let mode: SearchResultMode = text.isEmpty ? .searchInputSuggestion(recent: input) : .searchResult
    
    searchResultModeRelay.accept(mode)
  }
  
  func enterSearchInput(_ input: String) {
    guard !input.isEmpty else {
      titleSearchInputRelay.accept(input)
      hashTagSearchInputRelay.accept(input)
      return
    }
    
    switch searchMode {
      case .title: titleSearchInputRelay.accept(input)
      case .hashTag: hashTagSearchInputRelay.accept(input)
    }
    
    useCase.saveSearchKeyword(input)
  }
  
  func deleteAllRecentSearchInputs() {
    useCase.clearSearchHistory()
    searchResultModeRelay.accept(.searchInputSuggestion(recent: []))
  }
  
  func deleteRecentSearchInput(_ input: String) {
    let searchHistories = useCase.deleteSearchKeyword(input)
    searchResultModeRelay.accept(.searchInputSuggestion(recent: searchHistories))
  }
}
