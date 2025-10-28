//
//  TempPasswordViewModel.swift
//  LogInImpl
//
//  Created by wooseob on 6/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol TempPasswordCoordinatable: AnyObject {
  func didTapBackButton()
  func attachNewPassword()
}

protocol TempPasswordViewModelType {
  associatedtype Input
  associatedtype Output
  
  var coordinator: TempPasswordCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class TempPasswordViewModel: TempPasswordViewModelType {
  private let disposeBag = DisposeBag()
  private let useCase: LogInUseCase
  private let email: String
  private let name: String
  
  weak var coordinator: TempPasswordCoordinatable?
  
  private let invalidPasswordRelay = PublishRelay<Void>()
  private let networkUnstableRelay = PublishRelay<Void>()
  private let isSuccessedResendRelay = PublishRelay<Bool>()

  // MARK: - Input
  struct Input {
    let password: Driver<String>
    let didTapBackButton: Signal<Void>
    let didTapResendButton: Signal<Void>
    let didTapNextButton: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let isEnabledNextButton: Driver<Bool>
    let isSuccessedResend: Signal<Bool>
    let invalidPassword: Signal<Void>
    let networkUnstable: Signal<Void>
  }
  
  // MARK: - Initializers
  init(
    useCase: LogInUseCase,
    email: String,
    name: String
  ) {
    self.useCase = useCase
    self.email = email
    self.name = name
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.disposed(by: disposeBag)
    
    input.didTapResendButton
      .emit(with: self) { owner, _ in
        Task { await owner.requestTempoaryPassword() }
      }.disposed(by: disposeBag)
    
    input.didTapNextButton
      .withLatestFrom(input.password)
      .emit(with: self) { owner, password in
        Task { await owner.validateTemporaryPassword(password) }
      }.disposed(by: disposeBag)
    
    let isEnabledNextButton = input.password.map { !$0.isEmpty }
    
    return Output(
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false),
      isSuccessedResend: isSuccessedResendRelay.asSignal(),
      invalidPassword: invalidPasswordRelay.asSignal(),
      networkUnstable: networkUnstableRelay.asSignal()
    )
  }
}

// MARK: - API Methods
private extension TempPasswordViewModel {
  func requestTempoaryPassword() async {
    do {
      try await useCase.sendTemporaryPassword(to: email, userName: name)
      isSuccessedResendRelay.accept(true)
    } catch {
      isSuccessedResendRelay.accept(false)
    }
  }
  
  @MainActor func validateTemporaryPassword(_ password: String) async {
    let result = await useCase.verifyTemporaryPassword(password, name: name)

    switch result {
      case .success: coordinator?.attachNewPassword()
      case .mismatch: invalidPasswordRelay.accept(())
      case .failure: networkUnstableRelay.accept(())
    }
  }
}
