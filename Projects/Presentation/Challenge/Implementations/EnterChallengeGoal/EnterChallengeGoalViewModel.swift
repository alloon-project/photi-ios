//
//  EnterChallengeGoalViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import Entity
import UseCase

protocol EnterChallengeGoalCoordinatable: AnyObject {
  func didTapBackButton()
  func didFinishEnteringGoal(_ goal: String)
  func authenticatedFailed()
}

protocol EnterChallengeGoalViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: EnterChallengeGoalCoordinatable? { get set }
}

final class EnterChallengeGoalViewModel: EnterChallengeGoalViewModelType {
  weak var coordinator: EnterChallengeGoalCoordinatable?
  private var cancellables = Set<AnyCancellable>()
  private let mode: ChallengeGoalMode
  private let useCase: ChallengeUseCase
  private let challengeID: Int

  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  private let alreadyJoinedSubject = PassthroughSubject<Void, Never>()
  private let exceedChallengeMaximumSubject = PassthroughSubject<String, Never>()

  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let goalText: AnyPublisher<String, Never>
    let didTapSaveButton: AnyPublisher<Void, Never>
    let didTapSkipButton: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {
    let saveButtonIsEnabled: AnyPublisher<Bool, Never>
    let networkUnstable: AnyPublisher<Void, Never>
    let alreadyJoined: AnyPublisher<Void, Never>
    let exceedMaximumChallenge: AnyPublisher<String, Never>
  }

  // MARK: - Initializers
  init(
    mode: ChallengeGoalMode,
    challengeID: Int,
    useCase: ChallengeUseCase
  ) {
    self.mode = mode
    self.challengeID = challengeID
    self.useCase = useCase
  }

  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.store(in: &cancellables)

    input.didTapSaveButton
      .withLatestFrom(input.goalText)
      .sinkOnMain(with: self) { owner, goal in
        Task { await owner.handleGoalSubmission(goal) }
      }.store(in: &cancellables)

    input.didTapSkipButton
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.handleSkipEnteredGoal() }
      }.store(in: &cancellables)

    let saveButtonIsEnabled = input.goalText
      .map { !$0.isEmpty }
      .eraseToAnyPublisher()

    return Output(
      saveButtonIsEnabled: saveButtonIsEnabled,
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher(),
      alreadyJoined: alreadyJoinedSubject.eraseToAnyPublisher(),
      exceedMaximumChallenge: exceedChallengeMaximumSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension EnterChallengeGoalViewModel {
  func handleGoalSubmission(_ goal: String) async {
    switch mode {
    case .join:
      await joinChallenge(goal: goal)
    case .edit:
      await updateChallengeGoal(goal)
    }
  }

  func handleSkipEnteredGoal() async {
    if case .join = mode {
      await joinChallenge(goal: "")
    }
  }

  @MainActor func joinChallenge(goal: String) async {
    do {
      try await useCase.joinChallenge(id: challengeID, goal: goal)
      coordinator?.didFinishEnteringGoal(goal)
    } catch {
      requestFailed(with: error)
    }
  }

  @MainActor func updateChallengeGoal(_ goal: String) async {
    do {
      try await useCase.updateChallengeGoal(goal, challengeId: challengeID)
      coordinator?.didFinishEnteringGoal(goal)
    } catch {
      requestFailed(with: error)
    }
  }

  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableSubject.send(()) }

    switch error {
    case .challengeFailed(reason: .challengeLimitExceed):
      let message = "챌린지는 최대 20개까지 참여할 수 있습니다."
      exceedChallengeMaximumSubject.send(message)
    case let .challengeFailed(reason) where reason == .alreadyJoinedChallenge:
      alreadyJoinedSubject.send(())

    case .authenticationFailed:
      coordinator?.authenticatedFailed()
    default:
      networkUnstableSubject.send(())
    }
  }
}
