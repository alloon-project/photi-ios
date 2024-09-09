//
//  EnterPasswordViewModel.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol EnterPasswordCoordinatable: AnyObject { 
  func didTapBackButton()
  func didTapContinueButton(userName: String)
}

protocol EnterPasswordViewModelType: AnyObject, EnterPasswordViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EnterPasswordCoordinatable? { get set }
}

final class EnterPasswordViewModel: EnterPasswordViewModelType {
  private let email: String
  private let verificationCode: String
  private let userName: String
  private let useCase: SignUpUseCase
  
  let disposeBag = DisposeBag()
  
  weak var coordinator: EnterPasswordCoordinatable?

  private var requestFailedRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    var password: ControlProperty<String>
    var reEnteredPassword: ControlProperty<String>
    var didTapBackButton: ControlEvent<Void>
    var didTapContinueButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    var containAlphabet: Driver<Bool>
    var containNumber: Driver<Bool>
    var containSpecial: Driver<Bool>
    var isValidRange: Driver<Bool>
    var isValidPassword: Driver<Bool>
    var correspondPassword: Driver<Bool>
    var isEnabledNextButton: Driver<Bool>
    var requestFailed: Signal<Void>
  }
  
  // MARK: - Initializers
  init(
    useCase: SignUpUseCase,
    email: String,
    verificationCode: String,
    userName: String
  ) {
    self.useCase = useCase
    self.email = email
    self.verificationCode = verificationCode
    self.userName = userName
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapContinueButton
      .withLatestFrom(
        Observable.zip(input.password, input.reEnteredPassword)
      )
      .bind(with: self) { owner, passwords in
        owner.register(password: passwords.0, reEnteredPassword: passwords.1)
      }
      .disposed(by: disposeBag)
    
    let containAlphabet = input.password
      .map { $0.contain("[a-zA-Z]") }
    
    let containNumber = input.password
      .map { $0.contain("[0-9]") }
    
    let containSpecial = input.password
      .map { $0.contain("[^a-zA-Z0-9]") }
    
    let isValidRange = input.password
      .map { $0.count >= 8 && $0.count <= 30 }
    
    let isValidPassword = Observable.combineLatest(
      containAlphabet, containNumber, containSpecial, isValidRange
    ) { $0 && $1 && $2 && $3 }
    
    let correspondPassword = Observable.combineLatest(
      input.password, input.reEnteredPassword
    ) { $0 == $1 }
    
    let isEnabledNextButton = Observable.combineLatest(
      isValidPassword, correspondPassword
    ) { $0 && $1 }
    
    return Output(
      containAlphabet: containAlphabet.asDriver(onErrorJustReturn: false),
      containNumber: containNumber.asDriver(onErrorJustReturn: false),
      containSpecial: containSpecial.asDriver(onErrorJustReturn: false),
      isValidRange: isValidRange.asDriver(onErrorJustReturn: false),
      isValidPassword: isValidPassword.asDriver(onErrorJustReturn: false), 
      correspondPassword: correspondPassword.asDriver(onErrorJustReturn: false),
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension EnterPasswordViewModel {
  func register(password: String, reEnteredPassword: String) {
    useCase.register(
      email: email,
      verificationCode: verificationCode,
      usernmae: userName,
      password: password,
      passwordReEnter: reEnteredPassword
    )
    .observe(on: MainScheduler.instance)
    .subscribe(
      with: self,
      onSuccess: { owner, userName in
        owner.coordinator?.didTapContinueButton(userName: userName)
      },
      onFailure: { owner, _ in
        owner.requestFailedRelay.accept(())
      }
    )
    .disposed(by: disposeBag)
  }
}
