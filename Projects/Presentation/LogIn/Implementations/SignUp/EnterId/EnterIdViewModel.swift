//
//  EnterIdViewModel.swift
//  LogInImpl
//
//  Created by jung on 6/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol EnterIdCoordinatable: AnyObject { 
  func didTapBackButton()
  func didTapNextButton(userName: String)
}

protocol EnterIdViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EnterIdCoordinatable? { get set }
}

final class EnterIdViewModel: EnterIdViewModelType {
  let disposeBag = DisposeBag()
  private let useCase: SignUpUseCase
  
  weak var coordinator: EnterIdCoordinatable?
  
  private let inValidIdFormRelay = PublishRelay<Void>()
  private let duplicateIdRelay = PublishRelay<Void>()
  private let validIdRelay = PublishRelay<Void>()
  private let requestFailedRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input { 
    var didTapBackButton: ControlEvent<Void>
    var didTapNextButton: ControlEvent<Void>
    var didTapVerifyIdButton: ControlEvent<Void>
    var userId: ControlProperty<String>
  }
  
  // MARK: - Output
  struct Output { 
    var inValidIdForm: Signal<Void>
    var duplicateId: Signal<Void>
    var validId: Signal<Void>
    var isDuplicateButtonEnabled: Signal<Bool>
    var requestFailed: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: SignUpUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapNextButton
      .withLatestFrom(input.userId)
      .subscribe(with: self) { owner, userName in
        owner.coordinator?.didTapNextButton(userName: userName)
      }
      .disposed(by: disposeBag)
    
    input.didTapVerifyIdButton
      .withLatestFrom(input.userId)
      .subscribe(with: self) { owner, userId in
        owner.verifyUseName(userId)
      }
      .disposed(by: disposeBag)
    
    return Output(
      inValidIdForm: inValidIdFormRelay.asSignal(),
      duplicateId: duplicateIdRelay.asSignal(),
      validId: validIdRelay.asSignal(),
      isDuplicateButtonEnabled: input.userId.map { !$0.isEmpty }.asSignal(onErrorJustReturn: false),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension EnterIdViewModel {
  func verifyUseName(_ useName: String) {
    guard useName.isValidateId else {
      inValidIdFormRelay.accept(())
      return
    }
    
    useCase.verifyUseName(useName)
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { owner, _ in
          owner.validIdRelay.accept(())
        },
        onFailure: { owner, error in
          owner.requestFailed(error: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func requestFailed(error: Error) {
    if
      let error = error as? APIError,
      case .signUpFailed(let reason) = error {
      if case .useNameAlreadyExists = reason {
        duplicateIdRelay.accept(())
      } else {
        requestFailedRelay.accept(())
      }
    } else {
      requestFailedRelay.accept(())
    }
  }
}
