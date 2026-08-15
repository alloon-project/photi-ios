//
//  NoneMemberHomeViewModel.swift
//  HomeImpl
//
//  Created by jung on 9/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Combine

protocol NoneMemberHomeCoordinatable: AnyObject {
  func didTapLogInButton()
}

protocol NoneMemberHomeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: NoneMemberHomeCoordinatable? { get set }
}

final class NoneMemberHomeViewModel: NoneMemberHomeViewModelType {
  private var cancellables = Set<AnyCancellable>()

  weak var coordinator: NoneMemberHomeCoordinatable?

  // MARK: - Input
  struct Input {
    let didTapLogInButton: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output { }

  // MARK: - Initializers
  init() { }

  @discardableResult
  func transform(input: Input) -> Output {
    input.didTapLogInButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapLogInButton()
      }
      .store(in: &cancellables)

    return Output()
  }
}
