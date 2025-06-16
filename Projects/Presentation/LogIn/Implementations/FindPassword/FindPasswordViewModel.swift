//
//  FindPasswordViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import RxCocoa
import RxSwift
import Entity
import UseCase

protocol FindPasswordCoordinatable: AnyObject {
  func didTapBackButton()
  func attachResetPassword(userEmail: String, userName: String)
}

protocol FindPasswordViewModelType {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FindPasswordCoordinatable? { get }
}

final class FindPasswordViewModel: FindPasswordViewModelType {
  weak var coordinator: FindPasswordCoordinatable?
  
  private let disposeBag = DisposeBag()
  private let useCase: LogInUseCase
  private let unMatchedIdOrEmailIdOrEmailRelay = PublishRelay<Void>()
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: Signal<Void>
    let userId: Driver<String>
    let endEditingUserId: Signal<Void>
    let userEmail: Driver<String>
    let endEditingUserEmail: Signal<Void>
    let didTapNextButton: Signal<Void>
  }
  
  // MARK: - Output
  struct Output { 
    let inValidIdFormat: Signal<Void>
    let inValidEmailFormat: Signal<Void>
    let isEnabledNextButton: Signal<Bool>
    let unMatchedIdOrEmail: Signal<Void>
    let networkUnstable: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: LogInUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.disposed(by: disposeBag)
        
    let isValidIdFormat = input.endEditingUserId
      .withLatestFrom(input.userId)
      .map { $0.isValidateId }
    
    let isValidEmailFormat = input.endEditingUserEmail
      .withLatestFrom(input.userEmail)
      .map { $0.isValidateEmail() && $0.count <= 100 && !$0.isEmpty }
    
    let isEnabledConfirm = Observable.combineLatest(isValidIdFormat.asObservable(), isValidEmailFormat.asObservable())
      .map { $0 && $1 }
    
    let idAndEmail = Observable.combineLatest(input.userId.asObservable(), input.userEmail.asObservable())
      .asDriver(onErrorJustReturn: ("", ""))
    
    input.didTapNextButton
      .withLatestFrom(idAndEmail)
      .emit(with: self) { owner, info in
        Task { await owner.requestTempoaryPassword(id: info.0, email: info.1) }
      }
      .disposed(by: disposeBag)
    
    return Output(
      inValidIdFormat: isValidIdFormat.filter { !$0 }.map { _ in () }.asSignal(),
      inValidEmailFormat: isValidEmailFormat.filter { !$0 }.map { _ in () }.asSignal(),
      isEnabledNextButton: isEnabledConfirm.asSignal(onErrorJustReturn: false),
      unMatchedIdOrEmail: unMatchedIdOrEmailIdOrEmailRelay.asSignal(),
      networkUnstable: networkUnstableRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension FindPasswordViewModel {
  @MainActor func requestTempoaryPassword(id: String, email: String) async {
    do {
      try await useCase.sendTemporaryPassword(to: email, userName: id).value
      coordinator?.attachResetPassword(userEmail: email, userName: id)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    if let error = error as? APIError, case .userNotFound = error {
      unMatchedIdOrEmailIdOrEmailRelay.accept(())
    } else {
      networkUnstableRelay.accept(())
    }
  }
}
