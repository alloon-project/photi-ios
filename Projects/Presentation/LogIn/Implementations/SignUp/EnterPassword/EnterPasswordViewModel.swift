//
//  EnterPasswordViewModel.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine

protocol EnterPasswordCoordinatable: AnyObject {
  func didTapBackButton()
  func didTapContinueButton(password: String)
}

protocol EnterPasswordViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: EnterPasswordCoordinatable? { get set }
}

final class EnterPasswordViewModel: EnterPasswordViewModelType {
  private var cancellables = Set<AnyCancellable>()
  
  weak var coordinator: EnterPasswordCoordinatable?

  // MARK: - Input
  struct Input {
    let password: AnyPublisher<String, Never>
    let reEnteredPassword: AnyPublisher<String, Never>
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapContinueButton: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let containAlphabet: AnyPublisher<Bool, Never>
    let containNumber: AnyPublisher<Bool, Never>
    let containSpecial: AnyPublisher<Bool, Never>
    let isValidRange: AnyPublisher<Bool, Never>
    let isValidPassword: AnyPublisher<Bool, Never>
    let correspondPassword: AnyPublisher<Bool, Never>
    let isEnabledNextButton: AnyPublisher<Bool, Never>
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.store(in: &cancellables)
    
    input.didTapContinueButton
      .withLatestFrom(input.password)
      .sinkOnMain(with: self) { owner, password in
        owner.coordinator?.didTapContinueButton(password: password)
      }.store(in: &cancellables)
    
    let containAlphabet = input.password
      .map { $0.contain("[a-zA-Z]") }
    
    let containNumber = input.password
      .map { $0.contain("[0-9]") }
    
    let containSpecial = input.password
      .map { $0.contain("[^a-zA-Z0-9]") }
    
    let isValidRange = input.password
      .map { $0.count >= 8 && $0.count <= 30 }
    
    let isValidPassword = containAlphabet.combineLatest(
      containNumber, containSpecial, isValidRange
    ) { $0 && $1 && $2 && $3 }
    
    let correspondPassword = input.password.combineLatest(input.reEnteredPassword) { $0 == $1 }
    
    let isEnabledNextButton = isValidPassword.eraseToAnyPublisher()
      .combineLatest(correspondPassword) { $0 && $1 }
    
    return Output(
      containAlphabet: containAlphabet.eraseToAnyPublisher(),
      containNumber: containNumber.eraseToAnyPublisher(),
      containSpecial: containSpecial.eraseToAnyPublisher(),
      isValidRange: isValidRange.eraseToAnyPublisher(),
      isValidPassword: isValidPassword.eraseToAnyPublisher(),
      correspondPassword: correspondPassword,
      isEnabledNextButton: isEnabledNextButton
    )
  }
}
