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
  func didTapNextButton()
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
  private let unAvailableIdRelay = PublishRelay<Void>()
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input { 
    let didTapBackButton: ControlEvent<Void>
    let didTapNextButton: ControlEvent<Void>
    let didTapVerifyIdButton: ControlEvent<Void>
    let userId: ControlProperty<String>
  }
  
  // MARK: - Output
  struct Output { 
    let inValidIdForm: Signal<Void>
    let duplicateId: Signal<Void>
    let validId: Signal<Void>
    let unAvailableId: Signal<Void>
    let isDuplicateButtonEnabled: Signal<Bool>
    let networkUnstable: Signal<Void>
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
        owner.useCase.configureUsername(userName)
        owner.coordinator?.didTapNextButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapVerifyIdButton
      .withLatestFrom(input.userId)
      .subscribe(with: self) { owner, userId in
        owner.verifyUserName(userId)
      }
      .disposed(by: disposeBag)
    
    let isDuplicateButtonEnabled = input.userId
      .map { $0.count }
      .map { $0 >= 5 && $0 <= 20 }
      .asSignal(onErrorJustReturn: false)
    
    return Output(
      inValidIdForm: inValidIdFormRelay.asSignal(),
      duplicateId: duplicateIdRelay.asSignal(),
      validId: validIdRelay.asSignal(),
      unAvailableId: unAvailableIdRelay.asSignal(),
      isDuplicateButtonEnabled: isDuplicateButtonEnabled,
      networkUnstable: networkUnstableRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension EnterIdViewModel {
  func verifyUserName(_ userName: String) {
    useCase.verifyUserName(userName)
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
    guard let error = error as? APIError else {
      return networkUnstableRelay.accept(())
    }
    
    switch error {
      case let .signUpFailed(reason) where reason == .userNameAlreadyExists:
        duplicateIdRelay.accept(())
      case let .signUpFailed(reason) where reason == .invalidUserNameFormat:
        inValidIdFormRelay.accept(())
      case let .signUpFailed(reason) where reason == .invalidUserName:
        unAvailableIdRelay.accept(())
      default:
        networkUnstableRelay.accept(())
    }
  }
}
