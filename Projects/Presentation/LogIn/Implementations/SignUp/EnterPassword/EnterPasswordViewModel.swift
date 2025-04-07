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

protocol EnterPasswordViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EnterPasswordCoordinatable? { get set }
}

final class EnterPasswordViewModel: EnterPasswordViewModelType {
  private let useCase: SignUpUseCase
  let disposeBag = DisposeBag()
  
  weak var coordinator: EnterPasswordCoordinatable?

  private let networkUnstableRelay = PublishRelay<Void>()
  private let registerErrorRelay = PublishRelay<String>()
  
  // MARK: - Input
  struct Input {
    let password: ControlProperty<String>
    let reEnteredPassword: ControlProperty<String>
    let didTapBackButton: ControlEvent<Void>
    let didTapContinueButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let containAlphabet: Driver<Bool>
    let containNumber: Driver<Bool>
    let containSpecial: Driver<Bool>
    let isValidRange: Driver<Bool>
    let isValidPassword: Driver<Bool>
    let correspondPassword: Driver<Bool>
    let isEnabledNextButton: Driver<Bool>
    let networkUnstable: Signal<Void>
    let registerError: Signal<String>
  }
  
  // MARK: - Initializers
  init(useCase: SignUpUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapContinueButton
      .withLatestFrom(input.password)
      .bind(with: self) { owner, passwords in
        owner.register(password: passwords)
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
      networkUnstable: networkUnstableRelay.asSignal(),
      registerError: registerErrorRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension EnterPasswordViewModel {
  func register(password: String) {
    useCase.register(password: password)
    .observe(on: MainScheduler.instance)
    .subscribe(
      with: self,
      onSuccess: { owner, userName in
        owner.coordinator?.didTapContinueButton(userName: userName)
      },
      onFailure: { owner, error in
        print(error)
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
      case let .signUpFailed(reason) where reason == .didNotVerifyEmail:
        let message = "이메일 인증이 진행되지 않았어요.\n이메일 인증을 다시 해주세요."
        registerErrorRelay.accept(message)
      case let .signUpFailed(reason) where reason == .userNameAlreadyExists:
        let message = "이미 존재하는 아이디입니다.\n아이디 검증을 다시 해주세요."
        registerErrorRelay.accept(message)
      case let .signUpFailed(reason) where reason == .emailAlreadyExists:
        let message = "해당 이메일로 이미 가입된 회원이 있습니다.\n이메일을 다시 입력하거나, 비밀번호 찾기는 진행해주세요."
        registerErrorRelay.accept(message)
      case let .signUpFailed(reason) where reason == .invalidUserName:
        let message = "사용할 수 없는 아이디입니다.\n아이디 입력을 다시 해주세요."
        registerErrorRelay.accept(message)
      default:
        networkUnstableRelay.accept(())
    }
  }
}
