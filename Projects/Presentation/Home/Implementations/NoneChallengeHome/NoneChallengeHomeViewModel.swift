//
//  NoneChallengeHomeViewModel.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Combine
import Entity
import UseCase

protocol NoneChallengeHomeCoordinatable: AnyObject {
  @MainActor func attachNoneMemberChallenge(challengeId: Int)
  @MainActor func attachChallengeOrganize()
}

protocol NoneChallengeHomeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: NoneChallengeHomeCoordinatable? { get set }
}

final class NoneChallengeHomeViewModel: NoneChallengeHomeViewModelType {
  private let useCase: HomeUseCase
  private var cancellables = Set<AnyCancellable>()

  weak var coordinator: NoneChallengeHomeCoordinatable?

  private let challengesSubject = PassthroughSubject<[ChallengePresentationModel], Never>()
  private let requestFailedSubject = PassthroughSubject<Void, Never>()

  // MARK: - Input
  struct Input {
    let viewDidLoad: AnyPublisher<Void, Never>
    let requestJoinChallenge: AnyPublisher<Int, Never>
    let requestCreateChallenge: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {
    let challenges: AnyPublisher<[ChallengePresentationModel], Never>
    let requestFailed: AnyPublisher<Void, Never>
  }

  // MARK: - Initializers
  init(useCase: HomeUseCase) {
    self.useCase = useCase
  }

  func transform(input: Input) -> Output {
    input.viewDidLoad
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.fetchPopularChallenge() }
      }
      .store(in: &cancellables)

    input.requestJoinChallenge
      .sinkOnMain(with: self) { owner, id in
        Task { await owner.coordinator?.attachNoneMemberChallenge(challengeId: id) }
      }
      .store(in: &cancellables)

    input.requestCreateChallenge
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.coordinator?.attachChallengeOrganize() }
      }
      .store(in: &cancellables)

    return Output(
      challenges: challengesSubject.eraseToAnyPublisher(),
      requestFailed: requestFailedSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Private Methods
private extension NoneChallengeHomeViewModel {
  func fetchPopularChallenge() async {
    do {
      let response = try await useCase.fetchPopularChallenge()
      let models = response.map { mapToChallengePresentationModel($0) }

      challengesSubject.send(models)
    } catch {
      requestFailedSubject.send(())
    }
  }
  
  func mapToChallengePresentationModel(_ challenge: ChallengeDetail) -> ChallengePresentationModel {
    let proveTime = challenge.proveTime.toString("HH:mm")
    let endDate = challenge.endDate.toString("yyyy.MM.dd")
    
    return .init(
      id: challenge.id,
      name: challenge.name,
      imageURL: challenge.imageUrl,
      goal: challenge.goal,
      proveTime: proveTime,
      endDate: endDate,
      numberOfPersons: challenge.memberCount,
      hashTags: challenge.hashTags,
      memberImageURLs: challenge.memberImages
    )
  }
}
