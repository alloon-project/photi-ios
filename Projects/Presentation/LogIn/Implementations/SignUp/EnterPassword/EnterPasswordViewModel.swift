//
//  EnterPasswordViewModel.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine
import Entity
import UseCase

protocol EnterPasswordCoordinatable: AnyObject { 
  func didTapBackButton()
  func didTapContinueButton(userName: String)
}

protocol EnterPasswordViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: EnterPasswordCoordinatable? { get set }
}

final class EnterPasswordViewModel: EnterPasswordViewModelType {
  private var cancellables = Set<AnyCancellable>()
  private let useCase: SignUpUseCase
  
  weak var coordinator: EnterPasswordCoordinatable?

  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  private let registerErrorSubject = PassthroughSubject<String, Never>()

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
    let networkUnstable: AnyPublisher<Void, Never>
    let registerError: AnyPublisher<String, Never>
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
    
    input.didTapContinueButton
      .withLatestFrom(input.password)
      .sink(with: self) { owner, passwords in
        Task { await owner.register(password: passwords) }
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
      isEnabledNextButton: isEnabledNextButton,
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher(),
      registerError: registerErrorSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Private Methods
private extension EnterPasswordViewModel {
  func register(password: String) async {
    do {
      let userName = try await useCase.register(password: password)
      coordinator?.didTapContinueButton(userName: userName)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableSubject.send(())
    }
    
    switch error {
      case let .signUpFailed(reason) where reason == .didNotVerifyEmail:
        let message = "이메일 인증이 진행되지 않았어요.\n이메일 인증을 다시 해주세요."
        registerErrorSubject.send(message)
      case let .signUpFailed(reason) where reason == .userNameAlreadyExists:
        let message = "이미 존재하는 아이디입니다.\n아이디 검증을 다시 해주세요."
        registerErrorSubject.send(message)
      case let .signUpFailed(reason) where reason == .emailAlreadyExists:
        let message = "해당 이메일로 이미 가입된 회원이 있습니다.\n이메일을 다시 입력하거나, 비밀번호 찾기는 진행해주세요."
        registerErrorSubject.send(message)
      case let .signUpFailed(reason) where reason == .invalidUserName:
        let message = "사용할 수 없는 아이디입니다.\n아이디 입력을 다시 해주세요."
        registerErrorSubject.send(message)
      default:
        networkUnstableSubject.send(())
    }
  }
}
