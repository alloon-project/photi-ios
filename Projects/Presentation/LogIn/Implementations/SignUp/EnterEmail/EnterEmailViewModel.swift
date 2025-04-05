//
//  EnterEmailViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol EnterEmailCoordinatable: AnyObject {
  func attachVerifyEmail(userEmail: String)
  func didTapBackButton()
}

protocol EnterEmailViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EnterEmailCoordinatable? { get set }
}

final class EnterEmailViewModel: EnterEmailViewModelType {
  let disposeBag = DisposeBag()
  private let useCase: SignUpUseCase
  
  weak var coordinator: EnterEmailCoordinatable?
  
  private let duplicateEmailRelay = PublishRelay<Void>()
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapNextButton: ControlEvent<Void>
    let userEmail: ControlProperty<String>
    let endEditingUserEmail: ControlEvent<Void>
    let editingUserEmail: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let isValidEmailForm: Signal<Bool>
    let isOverMaximumText: Signal<Bool>
    let isEnabledNextButton: Signal<Bool>
    let duplicateEmail: Signal<Void>
    let networkUnstable: Signal<Void>
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
    
    input.didTapNextButton
      .withLatestFrom(input.userEmail)
      .bind(with: self) { owner, email in
        owner.requestVerificationCode(email: email)
      }
      .disposed(by: disposeBag)
    
    let isValidEmailForm = input.endEditingUserEmail
      .withLatestFrom(input.userEmail)
      .filter { $0.count <= 100 && !$0.isEmpty }
      .map { $0.isValidateEmail() }
    
    let isOverMaximumText = input.editingUserEmail
      .withLatestFrom(input.userEmail)
      .map { $0.count > 100 }
    
    let isEnabledConfirm = input.userEmail
      .map { $0.isValidateEmail() && $0.count <= 100 }
    
    return Output(
      isValidEmailForm: isValidEmailForm.asSignal(onErrorJustReturn: false),
      isOverMaximumText: isOverMaximumText.asSignal(onErrorJustReturn: true),
      isEnabledNextButton: isEnabledConfirm.asSignal(onErrorJustReturn: false),
      duplicateEmail: duplicateEmailRelay.asSignal(),
      networkUnstable: networkUnstableRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension EnterEmailViewModel {
  func requestVerificationCode(email: String) {
    useCase.requestVerificationCode(email: email)
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { owner, _ in
          owner.coordinator?.attachVerifyEmail(userEmail: email)
        },
        onFailure: { owner, error in
          owner.requestFailed(error: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func requestFailed(error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableRelay.accept(())
    }
    
    switch error {
      case let .signUpFailed(reason) where reason == .emailAlreadyExists:
        duplicateEmailRelay.accept(())
      default:
        networkUnstableRelay.accept(())
    }
  }
}
