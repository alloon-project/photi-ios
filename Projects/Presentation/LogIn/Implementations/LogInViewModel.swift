//
//  LogInViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol LogInCoordinatable {
  func attachSignUp()
  func detachSignUp() 
  func attachFindId()
  func detachFindId()
  func attachFindPassword()
  func detachFindPassword()
}

// Input, Output ViewModel
protocol LogInViewModelType: LogInViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
}

class LogInViewModel: LogInViewModelType {
  let disposeBag = DisposeBag()
  
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
    return Output()
  }
}
