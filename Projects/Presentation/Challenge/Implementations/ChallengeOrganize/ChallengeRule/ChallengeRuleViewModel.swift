//
//  ChallengeRuleViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import UseCase

protocol ChallengeRuleCoordinatable: AnyObject {
  func didTapBackButtonAtChallengeRule()
  func didFinishAtChallengeRule(challengeRules: [String])
}

protocol ChallengeRuleViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: ChallengeRuleCoordinatable? { get set }
}

final class ChallengeRuleViewModel: ChallengeRuleViewModelType {
  private var cancellables = Set<AnyCancellable>()
  private let mode: ChallengeOrganizeMode
  private let useCase: OrganizeUseCase

  weak var coordinator: ChallengeRuleCoordinatable?

  private let isRuleSelectedSubject = CurrentValueSubject<Bool, Never>(false)

  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let challengeRules: AnyPublisher<[String], Never>
    let didTapNextButton: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {
    let isRuleSelected: AnyPublisher<Bool, Never>
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
        owner.coordinator?.didTapBackButtonAtChallengeRule()
      }.store(in: &cancellables)

    input.challengeRules
      .map { rules in
        let hasAtLeastOne = !rules.isEmpty
        let underLimit = rules.count <= 5
        return hasAtLeastOne && underLimit
      }
      .sinkOnMain(with: self) { owner, isSelected in
        owner.isRuleSelectedSubject.send(isSelected)
      }.store(in: &cancellables)

    input.didTapNextButton
      .withLatestFrom(input.challengeRules)
      .sinkOnMain(with: self) { owner, rules in
        owner.coordinator?.didFinishAtChallengeRule(challengeRules: rules)
        owner.useCase.configureChallengePayload(.rules(rules))
      }.store(in: &cancellables)

    return Output(
      isRuleSelected: isRuleSelectedSubject.eraseToAnyPublisher()
    )
  }
}
