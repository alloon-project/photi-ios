//
//  ChallengePreviewViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Combine
import CoreUI
import Entity
import UseCase

protocol ChallengePreviewCoordinatable: AnyObject {
  func didFinishOrganizeChallenge(challengeId: Int)
  func didTapBackButtonAtPreview()
}

protocol ChallengePreviewViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: ChallengePreviewCoordinatable? { get set }
}

final class ChallengePreviewViewModel: ChallengePreviewViewModelType, @unchecked Sendable {
  weak var coordinator: ChallengePreviewCoordinatable?
  private var cancellables = Set<AnyCancellable>()

  private let useCase: OrganizeUseCase
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  private let exceedChallengeMaximumSubject = PassthroughSubject<String, Never>()
  private let emptyFileErrorSubject = PassthroughSubject<String, Never>()
  private let isLoadingSubject = PassthroughSubject<Bool, Never>()

  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapOrganizeButton: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {
    let isLoading: AnyPublisher<Bool, Never>
    let networkUnstable: AnyPublisher<Void, Never>
    let exceedChallengeMaximum: AnyPublisher<String, Never>
    let emptyFileError: AnyPublisher<String, Never>
  }

  // MARK: - Initializers
  init(useCase: OrganizeUseCase) {
    self.useCase = useCase
  }

  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtPreview()
      }.store(in: &cancellables)

    input.didTapOrganizeButton
      .throttle(for: .seconds(5), scheduler: DispatchQueue.main, latest: false)
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.organizeChallenge() }
      }.store(in: &cancellables)

    return Output(
      isLoading: isLoadingSubject.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher(),
      exceedChallengeMaximum: exceedChallengeMaximumSubject.eraseToAnyPublisher(),
      emptyFileError: emptyFileErrorSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Private Methods
private extension ChallengePreviewViewModel {}

// MARK: - API Methods
private extension ChallengePreviewViewModel {
  @MainActor func organizeChallenge() async {
    isLoadingSubject.send(true)

    do {
      let challenge = try await useCase.organizeChallenge()
      isLoadingSubject.send(false)
      coordinator?.didFinishOrganizeChallenge(challengeId: challenge.id)
    } catch {
      requestFailed(with: error)
      isLoadingSubject.send(false)
    }
  }

  func requestFailed(with error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableSubject.send(())
    }

    switch error {
    case .organazieFailed(.challengeLimitExceed):
      let message = "챌린지는 최대 20개까지 참여할 수 있습니다."
      exceedChallengeMaximumSubject.send(message)
    case .organazieFailed(.emptyFileInvalid):
      let message = "비어있는 파일은 저장할 수 없습니다."
      emptyFileErrorSubject.send(message)
    default:
      networkUnstableSubject.send(())
    }
  }
}
