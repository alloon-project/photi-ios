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
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapSignUpButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.attachSignUp()
      }
      .disposed(by: disposeBag)
    
    return Output()
  }
}
