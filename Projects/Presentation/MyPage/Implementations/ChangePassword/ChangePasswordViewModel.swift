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

protocol ChangePasswordViewModelType {
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
  private let containAlphabetRelay = PublishRelay<Bool>()
  private let containNumberRelay = PublishRelay<Bool>()
  private let containSpecialRelay = PublishRelay<Bool>()
  private let isValidRangeRelay = PublishRelay<Bool>()
  
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
    
    let isValidPassword = input.newPassword
      .withUnretained(self)
      .map { owner, password in
        owner.isValidPassword(password)
      }
    
    let correspondPassword = input.reEnteredPassword
      .withLatestFrom(input.currentPassword) { ($0, $1) }
      .map { $0 == $1 }
    
    let isEnabledNextButton = Observable.combineLatest(
      correspondPassword, isValidPassword
    )
      .map { $0 == $1 }
    
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
      containAlphabet: containAlphabetRelay.asDriver(onErrorJustReturn: false),
      containNumber: containNumberRelay.asDriver(onErrorJustReturn: false),
      containSpecial: containSpecialRelay.asDriver(onErrorJustReturn: false),
      isValidRange: isValidRangeRelay.asDriver(onErrorJustReturn: false),
      isValidPassword: isValidPassword.asDriver(onErrorJustReturn: false),
      correspondPassword: correspondPassword.asDriver(onErrorJustReturn: false),
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false),
      unMatchedCurrentPassword: unMatchedCurrentPasswordRelay.asSignal(),
      tokenUnauthorized: tokenUnauthorizedRelay.asSignal(),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension ChangePasswordViewModel {
  func isValidPassword(_ password: String) -> Bool {
    let containAlphabet = password.contain("[a-zA-Z]")
    let containNumber = password.contain("[0-9]")
    let containSpecial = password.contain("[^a-zA-Z0-9]")
    let isValidRange = password.count >= 8 && password.count <= 30
    
    containAlphabetRelay.accept(containAlphabet)
    containNumberRelay.accept(containNumber)
    containSpecialRelay.accept(containSpecial)
    isValidRangeRelay.accept(isValidRange)
    
    return containAlphabet && containNumber && containSpecial && isValidRange
  }
  
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
