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
  func attachResetPassword(email: String, name: String)
  func authenticationFailed()
}

protocol ChangePasswordViewModelType {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ChangePasswordCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class ChangePasswordViewModel: ChangePasswordViewModelType {
  private let useCase: ProfileEditUseCase
  private let disposeBag = DisposeBag()
  
  private let name: String
  private let email: String
  
  weak var coordinator: ChangePasswordCoordinatable?
  
  private let invalidCurrentPasswordRelay = PublishRelay<Void>()
  private let duplicatePasswordRelay = PublishRelay<Void>()
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let currentPassword: ControlProperty<String>
    let newPassword: ControlProperty<String>
    let reEnteredPassword: ControlProperty<String>
    let didTapBackButton: ControlEvent<Void>
    let didTapForgetPasswordButton: ControlEvent<Void>
    let didTapChangePasswordButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let containAlphabet: Driver<Bool>
    let containNumber: Driver<Bool>
    let containSpecial: Driver<Bool>
    let isValidRange: Driver<Bool>
    let isValidNewPassword: Driver<Bool>
    let correspondNewPassword: Driver<Bool>
    let isEnabledNextButton: Driver<Bool>
    let invalidCurrentPassword: Signal<Void>
    let duplicatePassword: Signal<Void>
    let networkUnstable: Signal<Void>
  }
  
  // MARK: - Initializers
  init(email: String, name: String, useCase: ProfileEditUseCase) {
    self.email = email
    self.name = name
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    bind(input: input)
    
    let containAlphabet = input.newPassword
      .map { $0.contain("[a-zA-Z]") }
    
    let containNumber = input.newPassword
      .map { $0.contain("[0-9]") }
    
    let containSpecial = input.newPassword
      .map { $0.contain("[^a-zA-Z0-9]") }
    
    let isValidRange = input.newPassword
      .map { $0.count >= 8 && $0.count <= 30 }
    
    let isValidNewPassword = Observable.combineLatest(
      containAlphabet, containNumber, containSpecial, isValidRange
    ) { $0 && $1 && $2 && $3 }
    
    let correspondNewPassword = Observable.combineLatest(
      input.newPassword, input.reEnteredPassword
    ) { $0 == $1 }

    let isEnabledNextButton = Observable.combineLatest(
      isValidNewPassword, correspondNewPassword, input.currentPassword.map { $0.isValidPassword }
    ) { $0 && $1 && $2 }
        
    return Output(
      containAlphabet: containAlphabet.asDriver(onErrorJustReturn: false),
      containNumber: containNumber.asDriver(onErrorJustReturn: false),
      containSpecial: containSpecial.asDriver(onErrorJustReturn: false),
      isValidRange: isValidRange.asDriver(onErrorJustReturn: false),
      isValidNewPassword: isValidNewPassword.asDriver(onErrorJustReturn: false),
      correspondNewPassword: correspondNewPassword.asDriver(onErrorJustReturn: false),
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false),
      invalidCurrentPassword: invalidCurrentPasswordRelay.asSignal(),
      duplicatePassword: duplicatePasswordRelay.asSignal(),
      networkUnstable: networkUnstableRelay.asSignal()
    )
  }
  
  func bind(input: Input) {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapForgetPasswordButton
      .bind(with: self) { owner, _ in
        Task { await owner.requestTempoaryPassword() }
      }
      .disposed(by: disposeBag)
    
    let passwords = Observable.combineLatest(
      input.currentPassword, input.newPassword
    )
    
    input.didTapChangePasswordButton
      .withLatestFrom(passwords)
      .subscribe(with: self) { owner, info in
        Task { await owner.changePassword(from: info.0, to: info.1) }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Methods
private extension ChangePasswordViewModel {
  @MainActor func changePassword(from password: String, to newPassword: String) async {
    guard password != newPassword else { return duplicatePasswordRelay.accept(()) }
      
    do {
      try await useCase.changePassword(from: password, to: newPassword)
      coordinator?.didChangedPassword()
    } catch {
      requestFailed(with: error)
    }
  }
  
  @MainActor func requestTempoaryPassword() async {
    do {
      try await useCase.sendTemporaryPassword(to: email, userName: name)
      coordinator?.attachResetPassword(email: email, name: name)
    } catch {
      networkUnstableRelay.accept(())
    }
  }
  
  @MainActor func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.accept(()) }
    
    switch error {
      case let .myPageFailed(reason) where reason == .loginUnAuthenticated:
        invalidCurrentPasswordRelay.accept(())
      case .authenticationFailed:
        coordinator?.authenticationFailed()
      default: networkUnstableRelay.accept(())
    }
  }
}
