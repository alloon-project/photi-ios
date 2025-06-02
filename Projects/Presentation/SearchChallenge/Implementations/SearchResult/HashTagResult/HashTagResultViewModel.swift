//
//  HashTagResultViewModel.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import UseCase

protocol HashTagResultCoordinatable: AnyObject {
  func didTapChallenge(challengeId: Int)
}

protocol HashTagResultViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: HashTagResultCoordinatable? { get set }
}

final class HashTagResultViewModel: HashTagResultViewModelType {
  weak var coordinator: HashTagResultCoordinatable?
  private let useCase: SearchUseCase
  private let modelMapper: SearchChallengePresentaionModelMapper
  
  private let disposeBag = DisposeBag()
  private let searchInput: Driver<String>
  private var isFetching = false
  private var isLastPage = false
  private var currentPage = 0
  private var fetchingChallengeTask: Task<Void, Never>?
  
  private let initialChallengesRelay = BehaviorRelay<[ResultChallengeCardPresentationModel]>(value: [])
  private let challengesRelay = BehaviorRelay<[ResultChallengeCardPresentationModel]>(value: [])
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let requestData: Signal<Void>
    let didTapChallenge: Signal<Int>
  }
  
  // MARK: - Output
  struct Output {
    let initialChallenges: Driver<[ResultChallengeCardPresentationModel]>
    let challenges: Driver<[ResultChallengeCardPresentationModel]>
    let networkUnstable: Signal<Void>
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
          await owner.fetchNextPage(for: input)
        }
      }
      .disposed(by: disposeBag)
    
    input.didTapChallenge
      .emit(with: self) { owner, id in
        owner.coordinator?.didTapChallenge(challengeId: id)
      }
      .disposed(by: disposeBag)
    
    return Output(
      initialChallenges: initialChallengesRelay.asDriver(),
      challenges: challengesRelay.asDriver(),
      networkUnstable: networkUnstableRelay.asSignal()
    )
  }
}

// MARK: - API Methods
private extension HashTagResultViewModel {
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
      let result = try await useCase.searchChallenge(
        byHashTag: keyword,
        page: currentPage,
        size: 15
      )
      let models = result.values.map {
        modelMapper.mapToResultChallengeCardFromSummary($0)
      }
      
      switch result {
        case .lastPage: isLastPage = true
        default: break
      }
      currentPage == 0 ? initialChallengesRelay.accept(models) : challengesRelay.accept(models)
    } catch {
      networkUnstableRelay.accept(())
    }
  }
}

// MARK: - Private Methods
private extension HashTagResultViewModel {
  func bind() {
    searchInput
      .drive(with: self) { owner, text in
        Task { await owner.resetAndfetchChallenges(for: text) }
      }
      .disposed(by: disposeBag)
  }
}
