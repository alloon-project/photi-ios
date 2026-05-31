//
//  DescriptionViewModel.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import CoreUI
import Entity
import UseCase

protocol DescriptionCoordinatable: AnyObject {
  func authenticatedFailed()
  func networkUnstable()
  func challengeNotFound()
}

protocol DescriptionViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: DescriptionCoordinatable? { get set }
}

final class DescriptionViewModel: DescriptionViewModelType {
  weak var coordinator: DescriptionCoordinatable?
  private let challengeId: Int
  private let useCase: ChallengeUseCase
  private var cancellables = Set<AnyCancellable>()

  private let descriptionSubject = CurrentValueSubject<ChallengeDescription?, Never>(nil)

  // MARK: - Input
  struct Input {
    let requestData: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {
    let rules: AnyPublisher<[String], Never>
    let proveTime: AnyPublisher<String, Never>
    let goal: AnyPublisher<String, Never>
    let duration: AnyPublisher<String, Never>
  }

  // MARK: - Initializers
  init(challengeId: Int, useCase: ChallengeUseCase) {
    self.challengeId = challengeId
    self.useCase = useCase
  }

  func transform(input: Input) -> Output {
    input.requestData
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.fetchDescription() }
      }
      .store(in: &cancellables)

    let descriptionPublisher = descriptionSubject.compactMap { $0 }.eraseToAnyPublisher()
    let proveTime = descriptionPublisher.map { $0.proveTime.toString("HH : mm") }.eraseToAnyPublisher()
    let duration = descriptionPublisher.map {
      "\($0.startDate.toString("yyyy.MM.dd")) ~ \($0.endDate.toString("yyyy-MM-dd"))"
    }.eraseToAnyPublisher()

    return Output(
      rules: descriptionPublisher.map { $0.rules }.eraseToAnyPublisher(),
      proveTime: proveTime,
      goal: descriptionPublisher.map { $0.goal }.eraseToAnyPublisher(),
      duration: duration
    )
  }
}

// MARK: - Private Methods
private extension DescriptionViewModel {
  func fetchDescription() async {
    do {
      let description = try await useCase.fetchChallengeDescription(id: challengeId)
      self.descriptionSubject.send(description)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else {
      coordinator?.networkUnstable(); return
    }
    
    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .challengeFailed(reason) where reason == .challengeNotFound:
        coordinator?.challengeNotFound()
      default:
        coordinator?.networkUnstable()
    }
  }
}
