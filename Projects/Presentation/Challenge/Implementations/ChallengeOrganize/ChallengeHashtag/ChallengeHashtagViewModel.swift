//
//  ChallengeHashtagViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import UseCase

protocol ChallengeHashtagCoordinatable: AnyObject {
  func didTapBackButtonAtChallengeHashtag()
  func didFinishedAtChallengeHashtag(challengeHashtags: [String])
}

protocol ChallengeHashtagViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: ChallengeHashtagCoordinatable? { get set }
}

final class ChallengeHashtagViewModel: ChallengeHashtagViewModelType {
  private var cancellables = Set<AnyCancellable>()
  private let mode: ChallengeOrganizeMode
  private let useCase: OrganizeUseCase

  weak var coordinator: ChallengeHashtagCoordinatable?

  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let enteredHashtag: AnyPublisher<String, Never>
    let selectedHashtags: AnyPublisher<[String], Never>
    let didTapNextButton: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {
    let isValidHashtag: AnyPublisher<Bool, Never>
    let isEnableAddHashtagButton: AnyPublisher<Bool, Never>
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
        owner.coordinator?.didTapBackButtonAtChallengeHashtag()
      }.store(in: &cancellables)

    input.didTapNextButton
      .withLatestFrom(input.selectedHashtags)
      .sinkOnMain(with: self) { owner, hashtags in
        owner.coordinator?.didFinishedAtChallengeHashtag(challengeHashtags: hashtags)
        owner.useCase.configureChallengePayload(.hashtags(hashtags))
      }.store(in: &cancellables)

    let isValidHashtag = input.enteredHashtag
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .map { !$0.isEmpty && $0.count <= 6 }

    let isEnableAddHashtagButton = isValidHashtag
      .combineLatest(input.selectedHashtags)
      .map { $0 && $1.count < 3 }

    let isEnabledNextButton = input.selectedHashtags
      .map { !$0.isEmpty }

    return Output(
      isValidHashtag: isValidHashtag.eraseToAnyPublisher(),
      isEnableAddHashtagButton: isEnableAddHashtagButton.eraseToAnyPublisher(),
      isEnabledNextButton: isEnabledNextButton.eraseToAnyPublisher()
    )
  }
}
