//
//  ChangePasswordViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol ChangePasswordCoordinatable: AnyObject {
  func didTapBackButton()
  func didChangedPassword()
}

protocol ChangePasswordViewModelType: ChangePasswordViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChangePasswordCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class ChangePasswordViewModel: ChangePasswordViewModelType {
  private let useCase: ChangePasswordUseCase
  let disposeBag = DisposeBag()
  
  weak var coordinator: ChangePasswordCoordinatable?
  
  private let unMatchedCurrentPasswordRelay = PublishRelay<Void>()
  private let tokenUnauthorizedRelay = PublishRelay<Void>()
  private let requestFailedRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    var currentPassword: ControlProperty<String>
    var newPassword: ControlProperty<String>
    var reEnteredPassword: ControlProperty<String>
    var didTapBackButton: ControlEvent<Void>
    var didTapChangePasswordButton: ControlEvent<Void>
    let didAppearAlert: PublishRelay<Void>
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
    var unMatchedCurrentPassword: Signal<Void>
    var tokenUnauthorized: Signal<Void>
    var requestFailed: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: ChangePasswordUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    let isDifferentPassword = Observable.combineLatest(
      input.currentPassword, input.newPassword
    ) { $0 != $1 }
    
    let containAlphabet = input.newPassword
      .map { $0.contain("[a-zA-Z]") }
    
    let containNumber = input.newPassword
      .map { $0.contain("[0-9]") }
    
    let containSpecial = input.newPassword
      .map { $0.contain("[^a-zA-Z0-9]") }
    
    let isValidRange = input.newPassword
      .map { $0.count >= 8 && $0.count <= 30 }
    
    let isValidPassword = Observable.combineLatest(
      containAlphabet, containNumber, containSpecial, isValidRange, isDifferentPassword
    ) { $0 && $1 && $2 && $3 && $4 }
    
    let correspondPassword = Observable.combineLatest(
      input.newPassword, input.reEnteredPassword
    ) { $0 == $1 }
    
    let isEnabledNextButton = Observable.combineLatest(
      isValidPassword, correspondPassword
    ) { $0 && $1 }
    
    input.didTapChangePasswordButton
      .withLatestFrom(Observable.combineLatest(
        input.currentPassword,
        input.newPassword,
        input.reEnteredPassword
      ))
      .subscribe(with: self) { owner, info in
        owner.changePassword(
          password: info.0,
          newPassword: info.1,
          newPasswordReEnter: info.2
        )
      }
      .disposed(by: disposeBag)
        
    return Output(
      containAlphabet: containAlphabet.asDriver(onErrorJustReturn: false),
      containNumber: containNumber.asDriver(onErrorJustReturn: false),
      containSpecial: containSpecial.asDriver(onErrorJustReturn: false),
      isValidRange: isValidRange.asDriver(onErrorJustReturn: false),
      isValidPassword: isValidPassword.asDriver(onErrorJustReturn: false),
      correspondPassword: correspondPassword.asDriver(onErrorJustReturn: false),
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false),
      unMatchedCurrentPassword: unMatchedCurrentPasswordRelay.asSignal(),
      tokenUnauthorized: tokenUnauthorizedRelay.asSignal(),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private
private extension ChangePasswordViewModel {
  func changePassword(
    password: String,
    newPassword: String,
    newPasswordReEnter: String
  ) {
    useCase.changePassword(
      password: password,
      newPassword: newPassword,
      newPasswordReEnter: newPasswordReEnter
    )
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { onwer, _ in
          onwer.coordinator?.didChangedPassword()
        },
        onFailure: { onwer, error in
          onwer.requestFailed(with: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func requestFailed(with error: Error) {
    if let error = error as? APIError {
      switch error {
      case .tokenUnauthorized:
        tokenUnauthorizedRelay.accept(())
      case .loginUnauthenticated:
        unMatchedCurrentPasswordRelay.accept(())
      default:
        break
      }
    } else {
      requestFailedRelay.accept(())
    }
  }
}
