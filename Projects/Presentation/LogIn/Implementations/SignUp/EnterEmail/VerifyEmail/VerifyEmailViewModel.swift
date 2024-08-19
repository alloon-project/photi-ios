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
  func didTapNextButton()
}

protocol VerifyEmailViewModelType: AnyObject, VerifyEmailViewModelable {
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
  
  private let requestFailedRelay = PublishRelay<Void>()
  private let invalidVerificationCodeRelay = PublishRelay<Void>()
  private let emailNotFoundRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    var didTapBackButton: ControlEvent<Void>
    var didTapResendButton: ControlEvent<Void>
    var didTapNextButton: ControlEvent<Void>
    var verificationCode: ControlProperty<String>
  }
  
  // MARK: - Output
  struct Output {
    var isEnabledNextButton: Signal<Bool>
    var requestFailed: Signal<Void>
    var invalidVerificationCode: Signal<Void>
    var emailNotFound: Signal<Void>
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
      requestFailed: requestFailedRelay.asSignal(),
      invalidVerificationCode: invalidVerificationCodeRelay.asSignal(),
      emailNotFound: emailNotFoundRelay.asSignal()
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
        onFailure: { owner, error in
          owner.requestFailed(error: error)
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
          owner.coordinator?.didTapNextButton()
        },
        onFailure: { owner, error in
          owner.requestFailed(error: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func requestFailed(error: Error) {
    print(error)
    if
      let error = error as? APIError,
      case .signUpFailed(let reason) = error {
      if case .invalidVerificationCode = reason {
        invalidVerificationCodeRelay.accept(())
      } else if case .emailNotFound = reason {
        emailNotFoundRelay.accept(())
      } else {
        requestFailedRelay.accept(())
      }
    } else {
      requestFailedRelay.accept(())
    }
  }
}
