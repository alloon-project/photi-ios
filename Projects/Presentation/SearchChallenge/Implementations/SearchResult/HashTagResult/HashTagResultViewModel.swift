//
//  HashTagResultViewModel.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import CoreUI
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
  
  private var cancellables = Set<AnyCancellable>()
  private let searchInput: AnyPublisher<String, Never>
  private var isFetching = false
  private var isLastPage = false
  private var currentPage = 0
  private var fetchingChallengeTask: Task<Void, Never>?
  
  private let initialChallengesRelay = CurrentValueSubject<[ResultChallengeCardPresentationModel], Never>([])
  private let challengesRelay = CurrentValueSubject<[ResultChallengeCardPresentationModel], Never>([])
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let requestData: AnyPublisher<Void, Never>
    let didTapChallenge: AnyPublisher<Int, Never>
  }
  
  // MARK: - Output
  struct Output {
    let initialChallenges: AnyPublisher<[ResultChallengeCardPresentationModel], Never>
    let challenges: AnyPublisher<[ResultChallengeCardPresentationModel], Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: SearchUseCase, searchInput: AnyPublisher<String, Never>) {
    self.useCase = useCase
    self.modelMapper = SearchChallengePresentaionModelMapper()
    self.searchInput = searchInput
    bind()
  }
  
  func transform(input: Input) -> Output {
    input.requestData
      .withLatestFrom(searchInput)
      .sinkOnMain(with: self) { owner, input in
        owner.fetchingChallengeTask = Task {
          await owner.fetchNextPage(for: input)
        }
      }
      .store(in: &cancellables)
    
    input.didTapChallenge
      .sinkOnMain(with: self) { owner, id in
        owner.coordinator?.didTapChallenge(challengeId: id)
      }
      .store(in: &cancellables)
    
    return Output(
      initialChallenges: initialChallengesRelay.eraseToAnyPublisher(),
      challenges: challengesRelay.eraseToAnyPublisher(),
      networkUnstable: networkUnstableRelay.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension HashTagResultViewModel {
  func resetAndfetchChallenges(for keyword: String) async {
    guard !keyword.isEmpty else {
      challengesRelay.send([])
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
      currentPage == 0 ? initialChallengesRelay.send(models) : challengesRelay.send(models)
    } catch {
      networkUnstableRelay.send(())
    }
  }
}

// MARK: - Private Methods
private extension HashTagResultViewModel {
  func bind() {
    searchInput
      .sinkOnMain(with: self) { owner, text in
        Task { await owner.resetAndfetchChallenges(for: text) }
      }
      .store(in: &cancellables)
  }
}
