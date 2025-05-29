//
//  ChallengeTitleResultViewModel.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import UseCase

protocol ChallengeTitleResultCoordinatable: AnyObject { }

protocol ChallengeTitleResultViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ChallengeTitleResultCoordinatable? { get set }
}

final class ChallengeTitleResultViewModel: ChallengeTitleResultViewModelType {
  weak var coordinator: ChallengeTitleResultCoordinatable?
  private let useCase: SearchUseCase
  private let modelMapper: SearchChallengePresentaionModelMapper
  private let disposeBag = DisposeBag()
  private let searchInput: Driver<String>
  private var isFetching = false
  private var isLastPage = false
  private var currentPage = 0
  private var fetchingChallengeTask: Task<Void, Never>?
  
  private let challengesRelay = BehaviorRelay<[ResultChallengeCardPresentationModel]>(value: [])

  // MARK: - Input
  struct Input {
    let requestData: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let challenges: Driver<[ResultChallengeCardPresentationModel]>
  }
  
  // MARK: - Initializers
  init(useCase: SearchUseCase, searchInput: Driver<String>) {
    self.useCase = useCase
    self.modelMapper = SearchChallengePresentaionModelMapper()
    self.searchInput = searchInput
    bind()
  }
  
  func transform(input: Input) -> Output {
    input.requestData
      .withLatestFrom(searchInput)
      .emit(with: self) { owner, input in
        owner.fetchingChallengeTask = Task {
          await owner.resetAndfetchChallenges(for: input)
        }
      }
      .disposed(by: disposeBag)
    
    return Output(challenges: challengesRelay.asDriver())
  }
}

// MARK: - API Methods
private extension ChallengeTitleResultViewModel {
  func resetAndfetchChallenges(for keyword: String) async {
    guard !keyword.isEmpty else {
      challengesRelay.accept([])
      isLastPage = true
      return
    }
  
    fetchingChallengeTask?.cancel()
    currentPage = 0
    isLastPage = false
    isFetching = false
    await fetchNextPage(for: keyword)
  }
  
  func fetchNextPage(for keyword: String) async {
    guard !Task.isCancelled else { return }
    guard !isLastPage && !isFetching else { return }
    isFetching = true
    
    defer {
      isFetching = false
      currentPage += 1
    }
    
    do {
      try await fetchChallengeData(for: keyword)
      guard !Task.isCancelled else { return }
      // 구현 예정
    } catch {
      // 구현 예정
    }
  }
  
  func fetchChallengeData(for keyword: String) async throws { }
}

// MARK: - Private Methods
private extension ChallengeTitleResultViewModel {
  func bind() {
    searchInput
      .drive(with: self) { owner, text in
        Task { await owner.resetAndfetchChallenges(for: text) }
      }
      .disposed(by: disposeBag)
  }
}
