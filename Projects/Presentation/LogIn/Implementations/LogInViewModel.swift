//
//  LogInViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol LogInCoordinatable: AnyObject {
  func attachSignUp()
  func detachSignUp() 
  func attachFindId()
  func detachFindId()
  func attachFindPassword()
  func detachFindPassword()
}

protocol LogInViewModelType: LogInViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: LogInCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

class LogInViewModel: LogInViewModelType {
  let disposeBag = DisposeBag()
  weak var coordinator: LogInCoordinatable?
  
  private let isValidIdOrPasswordRelay = PublishRelay<Void>()
  
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
    var isValidIdOrPassword: Signal<Void>
  }
  
  // MARK: - Initializers
  init() { }
  
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
      .subscribe(with: self) { owner, _ in
        owner.requestLogin()
      }
      .disposed(by: disposeBag)
    
    return Output(
      emptyIdOrPassword: emptyIdOrPassword.asSignal(onErrorJustReturn: ()),
      isValidIdOrPassword: isValidIdOrPasswordRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension LogInViewModel {
  func requestLogin() {
    // TODO: API 연결 후 구현
  }
}
