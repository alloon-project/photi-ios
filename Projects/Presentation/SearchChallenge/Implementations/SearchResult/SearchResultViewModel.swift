//
//  SearchResultViewModel.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

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
  weak var coordinator: SearchResultCoordinatable?
  private let disposeBag = DisposeBag()
  // TODO: - API 작업 이후 수정 예정
  private var recentSearchInputs = ["건강", "운동하기", "코딩코딩코딩", "밥 잘먹기"]
  
  private let searchResultModeRelay = BehaviorRelay<SearchResultMode>(value: .searchInputSuggestion(recent: []))

  // MARK: - Input
  struct Input {
    let didTapBackButton: Signal<Void>
    let searchText: Driver<String>
    let didEnterSearchText: Signal<String>
    let deleteAllRecentSearchInputs: Signal<Void>
    let deleteRecentSearchInput: Signal<String>
  }
  
  // MARK: - Output
  struct Output {
    let searchResultMode: Driver<SearchResultMode>
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.searchText
      .drive(with: self) { owner, text in
        owner.updateSearchResultMode(text)
      }
      .disposed(by: disposeBag)
    
    input.didEnterSearchText
      .emit(with: self) { owner, text in
        owner.enterSearchInput(text)
      }
      .disposed(by: disposeBag)
    
    input.deleteAllRecentSearchInputs
      .emit(with: self) { owner, _ in
        owner.deleteAllRecentSearchInputs()
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
    
    let mode: SearchResultMode = text.isEmpty ? .searchInputSuggestion(recent: recentSearchInputs) : .searchResult
    
    searchResultModeRelay.accept(mode)
  }
  
  func enterSearchInput(_ input: String) {
    recentSearchInputs = [input] + recentSearchInputs
  }
  
  func deleteAllRecentSearchInputs() {
    recentSearchInputs = []
    searchResultModeRelay.accept(.searchInputSuggestion(recent: []))
  }
  
  func deleteRecentSearchInput(_ input: String) {
    recentSearchInputs.removeAll { $0 == input }
    searchResultModeRelay.accept(.searchInputSuggestion(recent: recentSearchInputs))
  }
}
