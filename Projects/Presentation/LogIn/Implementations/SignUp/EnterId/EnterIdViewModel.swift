//
//  EnterIdViewModel.swift
//  LogInImpl
//
//  Created by jung on 6/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine
import Entity
import UseCase

protocol EnterIdCoordinatable: AnyObject { 
  func didTapBackButton()
  func didTapNextButton()
}

protocol EnterIdViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: EnterIdCoordinatable? { get set }
}

final class EnterIdViewModel: EnterIdViewModelType {
  private var cancellables: Set<AnyCancellable> = []
  private let useCase: SignUpUseCase
  
  weak var coordinator: EnterIdCoordinatable?
  
  private let inValidIdFormSubject = PassthroughSubject<Void, Never>()
  private let duplicateIdSubject = PassthroughSubject<Void, Never>()
  private let validIdSubject = PassthroughSubject<Void, Never>()
  private let unAvailableIdSubject = PassthroughSubject<Void, Never>()
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input { 
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapNextButton: AnyPublisher<Void, Never>
    let didTapVerifyIdButton: AnyPublisher<Void, Never>
    let userId: AnyPublisher<String, Never>
  }
  
  // MARK: - Output
  struct Output { 
    let inValidIdForm: AnyPublisher<Void, Never>
    let duplicateId: AnyPublisher<Void, Never>
    let validId: AnyPublisher<Void, Never>
    let unAvailableId: AnyPublisher<Void, Never>
    let isDuplicateButtonEnabled: AnyPublisher<Bool, Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: SignUpUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.store(in: &cancellables)
    
    input.didTapNextButton
      .withLatestFrom(input.userId)
      .sinkOnMain(with: self) { owner, userName in
        owner.useCase.configureUsername(userName)
        owner.coordinator?.didTapNextButton()
      }.store(in: &cancellables)
    input.didTapVerifyIdButton
      .withLatestFrom(input.userId)
      .sink(with: self) { owner, userId in
        Task { await owner.verifyUserName(userId) }
      }.store(in: &cancellables)
    
    let isDuplicateButtonEnabled = input.userId
      .map { $0.count }
      .map { $0 >= 5 && $0 <= 20 }
    
    return Output(
      inValidIdForm: inValidIdFormSubject.eraseToAnyPublisher(),
      duplicateId: duplicateIdSubject.eraseToAnyPublisher(),
      validId: validIdSubject.eraseToAnyPublisher(),
      unAvailableId: unAvailableIdSubject.eraseToAnyPublisher(),
      isDuplicateButtonEnabled: isDuplicateButtonEnabled.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Private Methods
private extension EnterIdViewModel {
  func verifyUserName(_ userName: String) async {
    do {
      try await useCase.verifyUserName(userName)
      validIdSubject.send(())
    } catch {
      requestFailed(error: error)
    }
  }
  
  func requestFailed(error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableSubject.send(())
    }
    
    switch error {
      case let .signUpFailed(reason) where reason == .userNameAlreadyExists:
        duplicateIdSubject.send(())
      case let .signUpFailed(reason) where reason == .invalidUserNameFormat:
        inValidIdFormSubject.send(())
      case let .signUpFailed(reason) where reason == .invalidUserName:
        unAvailableIdSubject.send(())
      default:
        return networkUnstableSubject.send(())
    }
  }
}
