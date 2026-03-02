//
//  AgreementViewModel.swift
//  LogInImpl
//
//  Created by Codex on 3/2/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

import Combine
import Entity
import UseCase

protocol AgreementCoordinatable: AnyObject {
  func didTapBackButton()
  func didFinishAgreement(userName: String)
}

protocol AgreementViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: AgreementCoordinatable? { get set }
}

final class AgreementViewModel: AgreementViewModelType {
  private var cancellables = Set<AnyCancellable>()
  private let useCase: SignUpUseCase
  private let password: String
  
  weak var coordinator: AgreementCoordinatable?
  
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  private let registerErrorSubject = PassthroughSubject<String, Never>()
  
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapContinueButton: AnyPublisher<Void, Never>
  }
  
  struct Output {
    let networkUnstable: AnyPublisher<Void, Never>
    let registerError: AnyPublisher<String, Never>
  }
  
  init(useCase: SignUpUseCase, password: String) {
    self.useCase = useCase
    self.password = password
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.store(in: &cancellables)
    
    input.didTapContinueButton
      .sink(with: self) { owner, _ in
        Task { await owner.register() }
      }.store(in: &cancellables)
    
    return Output(
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher(),
      registerError: registerErrorSubject.eraseToAnyPublisher()
    )
  }
}

private extension AgreementViewModel {
  func register() async {
    do {
      let userName = try await useCase.register(password: password)
      coordinator?.didFinishAgreement(userName: userName)
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
