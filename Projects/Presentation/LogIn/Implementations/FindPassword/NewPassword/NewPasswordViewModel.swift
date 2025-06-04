//
//  NewPasswordViewModel.swift
//  LogInImpl
//
//  Created by wooseob on 6/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import UseCase

protocol NewPasswordCoordinatable: AnyObject {
  func didTapBackButton()
  func didTapResetPasswordAlert()
}

protocol NewPasswordViewModelType {
  associatedtype Input
  associatedtype Output

  var coordinator: NewPasswordCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class NewPasswordViewModel: NewPasswordViewModelType {
  weak var coordinator: NewPasswordCoordinatable?

  private let disposeBag = DisposeBag()

  // MARK: - Input
  struct Input {
    let password: ControlProperty<String>
    let reEnteredPassword: ControlProperty<String>
    let didTapBackButton: Signal<Void>
    let didTapContinueButton: Signal<Void>
    let didTapConfirmButtonAtAlert: Signal<Void>
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
  }
  
  // MARK: - Initializers
  init(useCase: LogInUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
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
    
    // TODO: 비밀번호 재설정 요청 -> 성공시 팝업 팝업 끝나면 로그인으로 이동
    return Output(
      containAlphabet: containAlphabet.asDriver(onErrorJustReturn: false),
      containNumber: containNumber.asDriver(onErrorJustReturn: false),
      containSpecial: containSpecial.asDriver(onErrorJustReturn: false),
      isValidRange: isValidRange.asDriver(onErrorJustReturn: false),
      isValidPassword: isValidPassword.asDriver(onErrorJustReturn: false),
      correspondPassword: correspondPassword.asDriver(onErrorJustReturn: false),
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false)
    )
  }
}

// MARK: - API Methods
private extension NewPasswordViewModel { }
