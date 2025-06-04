//
//  FindIdViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol FindIdCoordinatable: AnyObject {
  func isRequestSucceed()
  func didTapBackButton()
}

protocol FindIdViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FindIdCoordinatable? { get set }
}

final class FindIdViewModel: FindIdViewModelType {
  weak var coordinator: FindIdCoordinatable?
  
  private let disposeBag = DisposeBag()
  private let useCase: LogInUseCase
  private let successEmailVerificationRelay = PublishRelay<Void>()
  private let notRegisteredEmailRelay = PublishRelay<Void>()
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: Signal<Void>
    let email: Driver<String>
    let endEditingUserEmail: Signal<Void>
    let didTapNextButton: Signal<Void>
    let didAppearAlert: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let successEmailVerification: Signal<Void>
    let notRegisteredEmail: Signal<Void>
    let invalidFormat: Signal<Void>
    let networkUnstable: Signal<Void>
    let isEnabledConfirm: Driver<Bool>
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

    input.didTapNextButton
      .withLatestFrom(input.email)
      .emit(with: self) { owner, email in
        Task { await owner.requestCheckEmail(email: email) }
      }
      .disposed(by: disposeBag)
    
    input.didAppearAlert
      .emit(with: self) { owner, _ in
        owner.coordinator?.isRequestSucceed()
      }
      .disposed(by: disposeBag)

    let inValidateEmail = input.endEditingUserEmail
      .withLatestFrom(input.email)
      .filter { !$0.isValidateEmail() || $0.count > 100 }
      .map { _ in () }
    
    let isEnabledConfirm = input.email
       .map { $0.isValidateEmail() && $0.count <= 100 }

    return Output(
      successEmailVerification: successEmailVerificationRelay.asSignal(),
      notRegisteredEmail: notRegisteredEmailRelay.asSignal(),
      invalidFormat: inValidateEmail.asSignal(onErrorJustReturn: ()),
      networkUnstable: networkUnstableRelay.asSignal(),
      isEnabledConfirm: isEnabledConfirm.asDriver(onErrorJustReturn: false)
    )
  }
}

// MARK: - Private Methods
private extension FindIdViewModel {
  func requestCheckEmail(email: String) {
    useCase.findId(userEmail: email)
      .subscribe(
        with: self,
        onSuccess: { owner, _ in
          owner.checkedEmailRelay.accept(())
        },
        onFailure: { owner, error in
          print(error)
          owner.requestFailed(error: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func requestFailed(error: Error) {
    if
      let error = error as? APIError,
      case .userNotFound = error {
      wrongEmailRelay.accept(())
    } else {
      requestFailedRelay.accept(())
    }
  }
}
