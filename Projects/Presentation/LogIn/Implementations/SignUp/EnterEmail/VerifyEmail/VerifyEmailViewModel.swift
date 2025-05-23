//
//  VerifyEmailViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol VerifyEmailCoordinatable: AnyObject {
  func didTapBackButton()
  func didTapNextButton(verificationCode: String)
}

protocol VerifyEmailViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: VerifyEmailCoordinatable? { get set }
}

final class VerifyEmailViewModel: VerifyEmailViewModelType {
  let disposeBag = DisposeBag()
  private let useCase: SignUpUseCase
  private let email: String
  
  weak var coordinator: VerifyEmailCoordinatable?
  
  private let networkUnstable = PublishRelay<Void>()
  private let invalidVerificationCodeRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapResendButton: ControlEvent<Void>
    let didTapNextButton: ControlEvent<Void>
    let verificationCode: ControlProperty<String>
  }
  
  // MARK: - Output
  struct Output {
    let isEnabledNextButton: Signal<Bool>
    let networkUnstable: Signal<Void>
    let invalidVerificationCode: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: SignUpUseCase, email: String) {
    self.useCase = useCase
    self.email = email
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)

    input.didTapNextButton
      .withLatestFrom(input.verificationCode)
      .filter { $0.count == 4 }
      .bind(with: self) { owner, code in
        owner.verifyCode(email: owner.email, code: code)
      }
      .disposed(by: disposeBag)
    
    input.didTapResendButton
      .bind(with: self) { owner, _ in
        owner.requestVerificationCode(email: owner.email)
      }
      .disposed(by: disposeBag)
    
    let isEnabledNextButton = input.verificationCode
      .map { $0.count == 4 }
      .asSignal(onErrorJustReturn: false)
    
    return Output(
      isEnabledNextButton: isEnabledNextButton,
      networkUnstable: networkUnstable.asSignal(),
      invalidVerificationCode: invalidVerificationCodeRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension VerifyEmailViewModel {
  func requestVerificationCode(email: String) {
    useCase.requestVerificationCode(email: email)
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onFailure: { owner, _ in
          owner.networkUnstable.accept(())
        }
      )
      .disposed(by: disposeBag)
  }
  
  func verifyCode(email: String, code: String) {
    useCase.verifyCode(email: email, code: code)
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { owner, _ in
          owner.coordinator?.didTapNextButton(verificationCode: code)
        },
        onFailure: { owner, error in
          owner.requestFailed(error: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func requestFailed(error: Error) {
    guard let error = error as? APIError else {
      return networkUnstable.accept(())
    }
    switch error {
      case let .signUpFailed(reason) where reason == .invalidVerificationCode:
        return invalidVerificationCodeRelay.accept(())
      default:
        return networkUnstable.accept(())
    }
  }
}
