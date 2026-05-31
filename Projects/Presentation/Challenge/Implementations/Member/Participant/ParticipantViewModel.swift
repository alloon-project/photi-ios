//
//  ParticipantViewModel.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import CoreUI
import Core
import Entity
import UseCase

protocol ParticipantCoordinatable: AnyObject {
  func didChangeContentOffset(_ offset: Double)
  func authenticatedFailed()
  func networkUnstable()
  func didTapEditButton(goal: String)
}

protocol ParticipantViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: ParticipantCoordinatable? { get set }
}

final class ParticipantViewModel: ParticipantViewModelType {
  weak var coordinator: ParticipantCoordinatable?
  let challengeId: Int
  let challengeName: String

  private var cancellables = Set<AnyCancellable>()
  private let useCase: ChallengeUseCase

  private let participantsSubject = CurrentValueSubject<[ParticipantPresentationModel], Never>([])

  // MARK: - Input
  struct Input {
    let requestData: AnyPublisher<Void, Never>
    let contentOffset: AnyPublisher<Double, Never>
    let didTapEditButton: AnyPublisher<String, Never>
  }

  // MARK: - Output
  struct Output {
    let participants: AnyPublisher<[ParticipantPresentationModel], Never>
  }

  // MARK: - Initializers
  init(challengeId: Int, challegeName: String, useCase: ChallengeUseCase) {
    self.challengeId = challengeId
    self.challengeName = challegeName
    self.useCase = useCase
  }

  func transform(input: Input) -> Output {
    input.requestData
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.fetchParticipants() }
      }
      .store(in: &cancellables)

    input.contentOffset
      .sinkOnMain(with: self) { owner, offSet in
        owner.coordinator?.didChangeContentOffset(offSet)
      }
      .store(in: &cancellables)

    input.didTapEditButton
      .sinkOnMain(with: self) { owner, goal in
        owner.coordinator?.didTapEditButton(goal: goal)
      }
      .store(in: &cancellables)

    return Output(participants: participantsSubject.eraseToAnyPublisher())
  }
}

// MARK: - Private Methods
private extension ParticipantViewModel {
  @MainActor func fetchParticipants() async {
    do {
      let members = try await useCase.fetchChallengeMembers(challengeId: challengeId)
      let models = members.map { mapToPresentationModel($0) }
      participantsSubject.send(models)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func mapToPresentationModel(_ member: ChallengeMember) -> ParticipantPresentationModel {
    return .init(
      name: member.name,
      avatarURL: member.imageUrl,
      duration: "\(member.duration)일째 활동 중",
      goal: member.goal,
      isChallengeOwner: member.isCreator,
      isSelf: ServiceConfiguration.shared.userName == member.name
    )
  }
  
  func requestFailed(with error: Error) {
    if let error = error as? APIError, case .authenticationFailed = error {
      coordinator?.authenticatedFailed()
    } else {
      coordinator?.networkUnstable()
    }
  }
}
