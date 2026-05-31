//
//  LogInGuideViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 1/31/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import CoreUI

protocol LogInGuideCoordinatable: AnyObject {
  func didTapBackButton()
  func didTapLogInButton()
}

protocol LogInGuideViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: LogInGuideCoordinatable? { get set }
}

final class LogInGuideViewModel: LogInGuideViewModelType {
  weak var coordinator: LogInGuideCoordinatable?
  private var cancellables = Set<AnyCancellable>()

  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapLogInButton: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output { }

  // MARK: - Initializers
  init() { }

  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .store(in: &cancellables)

    input.didTapLogInButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapLogInButton()
      }
      .store(in: &cancellables)

    return Output()
  }
}
