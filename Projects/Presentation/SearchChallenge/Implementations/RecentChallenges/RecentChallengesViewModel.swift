//
//  RecentChallengesViewModel.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import CoreUI
import UseCase

protocol RecentChallengesCoordinatable: AnyObject {
  func didTapChallenge(challengeId: Int)
}

protocol RecentChallengesViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: RecentChallengesCoordinatable? { get set }
}

final class RecentChallengesViewModel: RecentChallengesViewModelType {
  weak var coordinator: RecentChallengesCoordinatable?
  private let useCase: SearchUseCase
  private let modelMapper: SearchChallengePresentaionModelMapper
  private var cancellables = Set<AnyCancellable>()
  private var isFetching = false
  private var isLastPage = false
  private var currentPage = 0
  
  private let initialChallenges = CurrentValueSubject<[ChallengeCardPresentationModel], Never>([])
  private let challenges = CurrentValueSubject<[ChallengeCardPresentationModel], Never>([])
  
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()

  // MARK: - Input
  struct Input {
    let requestData: AnyPublisher<Void, Never>
    let didTapChallenge: AnyPublisher<Int, Never>
  }
  
  // MARK: - Output
  struct Output {
    let initialChallenges: AnyPublisher<[ChallengeCardPresentationModel], Never>
    let challenges: AnyPublisher<[ChallengeCardPresentationModel], Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: SearchUseCase) {
    self.useCase = useCase
    self.modelMapper = SearchChallengePresentaionModelMapper()
  }
  
  func transform(input: Input) -> Output {
    input.requestData
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.fetchChallenges() }
      }
      .store(in: &cancellables)
    
    input.didTapChallenge
      .sinkOnMain(with: self) { owner, id in
        owner.coordinator?.didTapChallenge(challengeId: id)
      }
      .store(in: &cancellables)
    
    return Output(
      initialChallenges: initialChallenges.eraseToAnyPublisher(),
      challenges: challenges.eraseToAnyPublisher(),
      networkUnstable: networkUnstableRelay.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension RecentChallengesViewModel {
  func fetchChallenges() async {
    guard !isLastPage && !isFetching else { return }
    
    isFetching = true
    
    defer {
      isFetching = false
      currentPage += 1
    }
      
    do {
      let result = try await useCase.recentChallenges(page: currentPage, size: 15)
      let models = result.values.map {
        modelMapper.mapToChallengeCardFromSummary($0)
      }

      switch result {
        case .lastPage: isLastPage = true
        default: break
      }
      currentPage == 0 ? initialChallenges.send(models) : challenges.send(models)
    } catch {
      networkUnstableRelay.send(())
    }
  }
}   
