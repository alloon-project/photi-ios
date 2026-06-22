//
//  SearchResultViewModel.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import CoreUI
import UseCase

protocol SearchResultCoordinatable: AnyObject {
  @MainActor func attachChallenge(id: Int)
  @MainActor func attachNonememberChallenge(id: Int)
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
  let titleSearchInput: AnyPublisher<String, Never>
  let hashTagSearchInput: AnyPublisher<String, Never>
  
  private let titleSearchInputRelay = CurrentValueSubject<String, Never>("")
  private let hashTagSearchInputRelay = CurrentValueSubject<String, Never>("")
  private var cancellables = Set<AnyCancellable>()
  private let useCase: SearchUseCase
  
  private let searchResultModeRelay = CurrentValueSubject<SearchResultMode, Never>(.searchInputSuggestion(recent: []))
  private var searchMode = SearchMode.title
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()

  // MARK: - Input
  struct Input {
    let viewDidLoad: AnyPublisher<Void, Never>
    let didTapBackButton: AnyPublisher<Void, Never>
    let searchText: AnyPublisher<String, Never>
    let deleteAllRecentSearchInputs: AnyPublisher<Void, Never>
    let deleteRecentSearchInput: AnyPublisher<String, Never>
    let searchMode: AnyPublisher<(mode: SearchMode, input: String), Never>
  }
  
  // MARK: - Output
  struct Output {
    let searchResultMode: AnyPublisher<SearchResultMode, Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: SearchUseCase) {
    self.useCase = useCase
    titleSearchInput = titleSearchInputRelay.eraseToAnyPublisher()
    hashTagSearchInput = hashTagSearchInputRelay.eraseToAnyPublisher()
  }
  
  func transform(input: Input) -> Output {
    input.viewDidLoad
      .sinkOnMain(with: self) { owner, _ in
        owner.updateSearchResultMode("")
      }
      .store(in: &cancellables)
    
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .store(in: &cancellables)
    
    input.searchText
      .sinkOnMain(with: self) { owner, text in
        owner.enterSearchInput(text)
        owner.updateSearchResultMode(text)
      }
      .store(in: &cancellables)

    input.deleteAllRecentSearchInputs
      .sinkOnMain(with: self) { owner, _ in
        owner.deleteAllRecentSearchInputs()
      }
      .store(in: &cancellables)
    
    input.searchMode
      .sinkOnMain(with: self) { owner, search in
        owner.searchMode = search.mode
        owner.enterSearchInput(search.input)
      }
      .store(in: &cancellables)
    
    input.deleteRecentSearchInput
      .sinkOnMain(with: self) { owner, input in
        owner.deleteRecentSearchInput(input)
      }
      .store(in: &cancellables)

    return Output(
      searchResultMode: searchResultModeRelay.eraseToAnyPublisher(),
      networkUnstable: networkUnstableRelay.eraseToAnyPublisher()
    )
  }
}

// MARK: - Internal Methods
extension SearchResultViewModel {
  @MainActor func decideRouteForChallenge(id: Int) async {
    do {
      let didJoined = try await useCase.didJoinedChallenge(id: id)
      
      didJoined ? coordinator?.attachChallenge(id: id) : coordinator?.attachNonememberChallenge(id: id)
    } catch {
      networkUnstableRelay.send(())
    }
  }
}

// MARK: - Private Methods
private extension SearchResultViewModel {
  func updateSearchResultMode(_ text: String) {
    guard text.isEmpty else { return searchResultModeRelay.send(.searchResult) }
    let input = useCase.searchHistory()
    let mode: SearchResultMode = text.isEmpty ? .searchInputSuggestion(recent: input) : .searchResult
    
    searchResultModeRelay.send(mode)
  }
  
  func enterSearchInput(_ input: String) {
    guard !input.isEmpty else {
      titleSearchInputRelay.send(input)
      hashTagSearchInputRelay.send(input)
      return
    }
    
    switch searchMode {
      case .title: titleSearchInputRelay.send(input)
      case .hashTag: hashTagSearchInputRelay.send(input)
    }
    
    useCase.saveSearchKeyword(input)
  }
  
  func deleteAllRecentSearchInputs() {
    useCase.clearSearchHistory()
    searchResultModeRelay.send(.searchInputSuggestion(recent: []))
  }
  
  func deleteRecentSearchInput(_ input: String) {
    let searchHistories = useCase.deleteSearchKeyword(input)
    searchResultModeRelay.send(.searchInputSuggestion(recent: searchHistories))
  }
}
