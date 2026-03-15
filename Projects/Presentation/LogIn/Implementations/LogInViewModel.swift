//
//  LogInViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine
import Entity
import UseCase
import KakaoSDKAuth
import KakaoSDKUser

protocol LogInCoordinatable: AnyObject {
  func attachSignUp()
  func attachOAuthSignUp(provider: String, idToken: String)
  func attachFindId()
  func attachFindPassword()
  func didFinishLogIn(userName: String)
  func didTapBackButton()
}

protocol LogInViewModelType {
  associatedtype Input
  associatedtype Output

  var coordinator: LogInCoordinatable? { get set }

  init(loginUseCase: LogInUseCase)

  func transform(input: Input) -> Output
}

final class LogInViewModel: LogInViewModelType {
  private var cancellables = Set<AnyCancellable>()
  weak var coordinator: LogInCoordinatable?

  private let loginUseCase: LogInUseCase
  private let loadingAnimationSubject = PassthroughSubject<Bool, Never>()
  private let invalidIdOrPasswordSubject = PassthroughSubject<Void, Never>()
  private let deletedUserSubject = PassthroughSubject<Void, Never>()
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let id: AnyPublisher<String, Never>
    let password: AnyPublisher<String, Never>
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapLoginButton: AnyPublisher<Void, Never>
    let didTapFindIdButton: AnyPublisher<Void, Never>
    let didTapFindPasswordButton: AnyPublisher<Void, Never>
    let didTapSignUpButton: AnyPublisher<Void, Never>
    let didTapAppleLoginButton: AnyPublisher<Void, Never>
    let didTapKakaoLoginButton: AnyPublisher<Void, Never>
    let didTapGoogleLoginButton: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let loadingAnimation: AnyPublisher<Bool, Never>
    let emptyIdOrPassword: AnyPublisher<Void, Never>
    let invalidIdOrPassword: AnyPublisher<Void, Never>
    let deletedUser: AnyPublisher<Void, Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(loginUseCase: LogInUseCase) {
    self.loginUseCase = loginUseCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapSignUpButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.attachSignUp()
      }.store(in: &cancellables)
    
    input.didTapFindIdButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.attachFindId()
      }.store(in: &cancellables)
    
    input.didTapFindPasswordButton
      .sink(with: self) { owner, _ in
        owner.coordinator?.attachFindPassword()
      }.store(in: &cancellables)
    
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.store(in: &cancellables)
    
    input.didTapAppleLoginButton
      .sinkOnMain(with: self) { owner, _ in
        // TODO: Apple 로그인 구현
      }.store(in: &cancellables)

    input.didTapKakaoLoginButton
      .sinkOnMain(with: self) { owner, _ in
        owner.requestKakaoLogin()
      }.store(in: &cancellables)

    input.didTapGoogleLoginButton
      .sinkOnMain(with: self) { owner, _ in
        // TODO: Google 로그인 구현
      }.store(in: &cancellables)
    
    let didTapLoginButtonWithInfo = input.didTapLoginButton
      .withLatestFrom(input.id.combineLatest(input.password))
      .share()
    
    let emptyIdOrPassword = didTapLoginButtonWithInfo
      .filter { $0.0.isEmpty || $0.1.isEmpty }
      .map { _ in () }
    
    didTapLoginButtonWithInfo
      .filter { !$0.0.isEmpty && !$0.1.isEmpty }
      .sink(with: self) { owner, info in
        Task { await owner.requestLogin(userName: info.0, password: info.1) }
      }.store(in: &cancellables)
    
    return Output(
      loadingAnimation: loadingAnimationSubject.eraseToAnyPublisher(),
      emptyIdOrPassword: emptyIdOrPassword.eraseToAnyPublisher(),
      invalidIdOrPassword: invalidIdOrPasswordSubject.eraseToAnyPublisher(),
      deletedUser: deletedUserSubject.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Private Methods
private extension LogInViewModel {
  func requestLogin(userName: String, password: String) async {
    loadingAnimationSubject.send(true)
    do {
      try await loginUseCase.login(username: userName, password: password)
      coordinator?.didFinishLogIn(userName: userName)
    } catch {
      loadingAnimationSubject.send(false)
      requestFailed(with: error)
    }
  }

  func requestKakaoLogin() {
    let loginCompletion: (OAuthToken?, Error?) -> Void = { [weak self] oauthToken, error in
      guard let self = self else { return }

      if error != nil {
        self.networkUnstableSubject.send(())
        return
      }

      guard let idToken = oauthToken?.idToken else {
        self.networkUnstableSubject.send(())
        return
      }

      Task { @MainActor in
        self.coordinator?.attachOAuthSignUp(provider: "KAKAO", idToken: idToken)
      }
    }

    if UserApi.isKakaoTalkLoginAvailable() {
      UserApi.shared.loginWithKakaoTalk(completion: loginCompletion)
    } else {
      UserApi.shared.loginWithKakaoAccount(completion: loginCompletion)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableSubject.send(())
    }
    
    switch error {
    case APIError.loginFailed(reason: .invalidEmailOrPassword):
        invalidIdOrPasswordSubject.send(())
    case APIError.loginFailed(reason: .deletedUser):
        deletedUserSubject.send(())
      default:
        networkUnstableSubject.send(())
    }
  }
}
