//
//  ChallengeNameViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import UseCase

protocol ChallengeNameCoordinatable: AnyObject {
  func didTapBackButtonAtChallengeName()
  func attachChallengeGoal(challengeName: String, isPublic: Bool)
}

protocol ChallengeNameViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: ChallengeNameCoordinatable? { get set }
}

final class ChallengeNameViewModel: ChallengeNameViewModelType {
  private var cancellables = Set<AnyCancellable>()
  private let mode: ChallengeOrganizeMode
  private let useCase: OrganizeUseCase

  weak var coordinator: ChallengeNameCoordinatable?

  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let challengeName: AnyPublisher<String, Never>
    let isPublicChallenge: AnyPublisher<Bool, Never>
    let didTapNextButton: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {}

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
        owner.coordinator?.didTapBackButtonAtChallengeName()
      }.store(in: &cancellables)

    input.didTapNextButton
      .withLatestFrom(input.challengeName.combineLatest(input.isPublicChallenge))
      .sinkOnMain(with: self) { owner, pieceOfChallenge in
        owner.coordinator?.attachChallengeGoal(
          challengeName: pieceOfChallenge.0,
          isPublic: pieceOfChallenge.1
        )
        owner.useCase.configureChallengePayload(.name(pieceOfChallenge.0))
        owner.useCase.configureChallengePayload(.isPublic(pieceOfChallenge.1))
      }.store(in: &cancellables)

    return Output()
  }
}
