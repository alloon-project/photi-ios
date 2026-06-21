//
//  EndedChallengeViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Combine
import CoreUI
import Entity
import UseCase

protocol EndedChallengeCoordinatable: AnyObject {
  @MainActor func attachChallenge(id: Int)
  func didTapBackButton()
  func authenticateFailed()
}

protocol EndedChallengeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: EndedChallengeCoordinatable? { get set }
}

final class EndedChallengeViewModel: EndedChallengeViewModelType {
  weak var coordinator: EndedChallengeCoordinatable?

  private let useCase: MyPageUseCase
  private var cancellables = Set<AnyCancellable>()
  private var isFetching = false
  private var isLastPage = false
  private var currentPage = 0

  private let endedChallengesRelay = CurrentValueSubject<[EndedChallengeCardPresentationModel], Never>([])
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let requestData: AnyPublisher<Void, Never>
    let didTapChallenge: AnyPublisher<Int, Never>
  }
  
  // MARK: - Output
  struct Output {
    let endedChallenges: AnyPublisher<[EndedChallengeCardPresentationModel], Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: MyPageUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .store(in: &cancellables)

    input.requestData
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.loadEndedChallenges() }
      }
      .store(in: &cancellables)
    
    input.didTapChallenge
      .sinkOnMain(with: self) { owner, id in
        Task { await owner.coordinator?.attachChallenge(id: id) }
      }
      .store(in: &cancellables)
    
    return Output(
      endedChallenges: endedChallengesRelay.eraseToAnyPublisher(),
      networkUnstable: networkUnstableRelay.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension EndedChallengeViewModel {
  func loadEndedChallenges() async {
    guard !isLastPage && !isFetching else { return }
    
    isFetching = true
    
    defer {
      isFetching = false
      currentPage += 1
    }
      
    do {
      let result = try await useCase.loadEndedChallenges(page: currentPage, size: 15)
      let models = result.values.map { mapToEndedPresentationModel($0) }
      endedChallengesRelay.send(models)
      
      switch result {
        case .lastPage: isLastPage = true
        default: break
      }
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.send(()) }
    
    if case .authenticationFailed = error {
      coordinator?.authenticateFailed()
    } else {
      networkUnstableRelay.send(())
    }
  }
}

// MARK: - Private Methods
private extension EndedChallengeViewModel {
  func mapToEndedPresentationModel(_ challenge: ChallengeSummary) -> EndedChallengeCardPresentationModel {
    let deadLine = challenge.endDate.toString("yyyy. MM. dd 종료")
    
    return .init(
      id: challenge.id,
      thumbnailUrl: challenge.imageUrl,
      title: challenge.name,
      deadLine: deadLine,
      currentMemberCnt: challenge.memberCount ?? 0,
      memberImageUrls: challenge.memberImages ?? []
    )
  }
}
