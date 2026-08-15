//
//  ChallengeStartViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine

protocol ChallengeStartCoordinatable: AnyObject {
  func didTapBackButton()
  func didFisishChallengeStart()
}

protocol ChallengeStartViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: ChallengeStartCoordinatable? { get set }
}

final class ChallengeStartViewModel: ChallengeStartViewModelType {
  private var cancellables = Set<AnyCancellable>()

  weak var coordinator: ChallengeStartCoordinatable?

  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapStartButton: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output { }

  // MARK: - Initializers
  init() { }

  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.store(in: &cancellables)

    input.didTapStartButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didFisishChallengeStart()
      }.store(in: &cancellables)

    return Output()
  }
}
