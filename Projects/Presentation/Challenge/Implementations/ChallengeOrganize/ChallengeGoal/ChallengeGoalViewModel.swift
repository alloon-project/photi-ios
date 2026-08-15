//
//  ChallengeGoalViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Combine
import UseCase

protocol ChallengeGoalCoordinatable: AnyObject {
  func didTapBackButtonAtChallengeGoal()
  func didFinishChallengeGoal(challengeGoal: String, proveTime: String, endDate: String)
}

protocol ChallengeGoalViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: ChallengeGoalCoordinatable? { get set }
}

final class ChallengeGoalViewModel: ChallengeGoalViewModelType {
  private var cancellables = Set<AnyCancellable>()
  private let mode: ChallengeOrganizeMode
  private let useCase: OrganizeUseCase

  weak var coordinator: ChallengeGoalCoordinatable?

  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let challengeGoal: AnyPublisher<String, Never>
    let proveTime: AnyPublisher<String, Never>
    let date: AnyPublisher<Date, Never>
    let didTapNextButton: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {
    let isEnabledNextButton: AnyPublisher<Bool, Never>
  }

  // MARK: - Initializers
  init(
    mode: ChallengeOrganizeMode,
    useCase: OrganizeUseCase
  ) {
    self.mode = mode
    self.useCase = useCase
  }

  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtChallengeGoal()
      }.store(in: &cancellables)

    let infos = input.challengeGoal
      .combineLatest(input.proveTime, input.date)

    input.didTapNextButton
      .withLatestFrom(infos)
      .sinkOnMain(with: self) { owner, infos in
        owner.coordinator?.didFinishChallengeGoal(
          challengeGoal: infos.0,
          proveTime: infos.1,
          endDate: infos.2.toString("YYYY-MM-dd")
        )
        owner.useCase.configureChallengePayload(.goal(infos.0))
        owner.useCase.configureChallengePayload(.proveTime(infos.1))
        owner.useCase.configureChallengePayload(.endDate(infos.2.toString("YYYY-MM-dd")))
      }.store(in: &cancellables)

    let isEnabledNextButton = input.challengeGoal
      .combineLatest(input.proveTime, input.date) { goal, time, date in
        let trimmedGoal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        let isValidGoal = !trimmedGoal.isEmpty && trimmedGoal.count >= 10
        let isValidTime = !time.isEmpty
        let isValidDate = date > Date()

        return isValidGoal && isValidTime && isValidDate
      }

    return Output(
      isEnabledNextButton: isEnabledNextButton.eraseToAnyPublisher()
    )
  }
}
