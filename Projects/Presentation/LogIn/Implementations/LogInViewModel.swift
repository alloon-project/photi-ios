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
  func attachSignUp()
  func detachSignUp()
  func attachFindId()
  func detachFindId()
  func attachFindPassword()
  func detachFindPassword()
  func didFinishLogIn(userName: String)
}

protocol LogInViewModelType: LogInViewModelable {
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
  private let invalidIdOrPasswordRelay = PublishRelay<Void>()
  private let requestFailedRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let id: ControlProperty<String>
    let password: ControlProperty<String>
    let didTapLoginButton: ControlEvent<Void>
    let didTapFindIdButton: ControlEvent<Void>
    let didTapFindPasswordButton: ControlEvent<Void>
    let didTapSignUpButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    var emptyIdOrPassword: Signal<Void>
    var invalidIdOrPassword: Signal<Void>
    var requestFailed: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: LogInUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapSignUpButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.attachSignUp()
      }
      .disposed(by: disposeBag)
    
    input.didTapFindIdButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.attachFindId()
      }
      .disposed(by: disposeBag)
    
    input.didTapFindPasswordButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.attachFindPassword()
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
      emptyIdOrPassword: emptyIdOrPassword.asSignal(onErrorJustReturn: ()),
      invalidIdOrPassword: invalidIdOrPasswordRelay.asSignal(),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension LogInViewModel {
  func requestLogin(userName: String, password: String) {
    useCase.login(username: userName, password: password)
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { owner, _ in
          owner.coordinator?.didFinishLogIn(userName: userName)
        },
        onFailure: { owner, error in
          owner.requestFailed(with: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func requestFailed(with error: Error) {
    if let error = error as? APIError, case .loginFailed = error {
      invalidIdOrPasswordRelay.accept(())
    } else {
      requestFailedRelay.accept(())
    }
  }
}
