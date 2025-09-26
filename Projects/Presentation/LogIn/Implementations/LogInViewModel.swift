//
//  LogInViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol LogInCoordinatable: AnyObject {
  @MainActor func attachSignUp()
  @MainActor func attachFindId()
  @MainActor func attachFindPassword()
  func didFinishLogIn(userName: String)
  func didTapBackButton()
}

protocol LogInViewModelType {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: LogInCoordinatable? { get set }
  
  init(useCase: LogInUseCase)
  
  func transform(input: Input) -> Output
}

final class LogInViewModel: LogInViewModelType {
  let disposeBag = DisposeBag()
  weak var coordinator: LogInCoordinatable?
  
  private let useCase: LogInUseCase
  private let loadingAnimationRelay = PublishRelay<Bool>()
  private let invalidIdOrPasswordRelay = PublishRelay<Void>()
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let id: ControlProperty<String>
    let password: ControlProperty<String>
    let didTapBackButton: ControlEvent<Void>
    let didTapLoginButton: ControlEvent<Void>
    let didTapFindIdButton: ControlEvent<Void>
    let didTapFindPasswordButton: ControlEvent<Void>
    let didTapSignUpButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let loadingAnmiation: Signal<Bool>
    let emptyIdOrPassword: Signal<Void>
    let invalidIdOrPassword: Signal<Void>
    let networkUnstable: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: LogInUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapSignUpButton
      .bind(with: self) { owner, _ in
        Task { await owner.coordinator?.attachSignUp() }
      }
      .disposed(by: disposeBag)
    
    input.didTapFindIdButton
      .bind(with: self) { owner, _ in
        Task { await owner.coordinator?.attachFindId() }
      }
      .disposed(by: disposeBag)
    
    input.didTapFindPasswordButton
      .bind(with: self) { owner, _ in
        Task { await owner.coordinator?.attachFindPassword() }
      }
      .disposed(by: disposeBag)
    
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    let didTapLoginButtonWithInfo = input.didTapLoginButton
      .withLatestFrom(Observable.combineLatest(input.id, input.password))
      .share()
    
    let emptyIdOrPassword = didTapLoginButtonWithInfo
      .filter { $0.0.isEmpty || $0.1.isEmpty }
      .map { _ in () }
    
    didTapLoginButtonWithInfo
      .filter { !$0.0.isEmpty && !$0.1.isEmpty }
      .subscribe(with: self) { owner, info in
        owner.requestLogin(userName: info.0, password: info.1)
      }
      .disposed(by: disposeBag)
    
    return Output(
      loadingAnmiation: loadingAnimationRelay.asSignal(),
      emptyIdOrPassword: emptyIdOrPassword.asSignal(onErrorJustReturn: ()),
      invalidIdOrPassword: invalidIdOrPasswordRelay.asSignal(),
      networkUnstable: networkUnstableRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension LogInViewModel {
  func requestLogin(userName: String, password: String) {
    loadingAnimationRelay.accept(true)
    useCase.login(username: userName, password: password)
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { owner, _ in
          owner.coordinator?.didFinishLogIn(userName: userName)
        },
        onFailure: { owner, error in
          owner.loadingAnimationRelay.accept(false)
          owner.requestFailed(with: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableRelay.accept(())
    }
    
    switch error {
      case .loginFailed:
        invalidIdOrPasswordRelay.accept(())
      default:
        networkUnstableRelay.accept(())
    }
  }
}
