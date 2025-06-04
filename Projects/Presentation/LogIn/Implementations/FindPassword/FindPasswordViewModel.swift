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
  func attachTempPassword(userEmail: String, userName: String)
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
  // TODO: 서버 연결 시 아이디 & 이메일 확인 로직 구현
  func findPassword(userEmail: String, userName: String) {
    useCase.findPassword(userEmail: userEmail, userName: userName)
      .subscribe(
        with: self,
        onSuccess: { onwer, _ in
          onwer.coordinator?.attachTempPassword(userEmail: userEmail, userName: userName)
        },
        onFailure: { onwer, err in
          print(err)
          onwer.invalidIdOrEmailRelay.accept(())
        }
      )
      .disposed(by: disposeBag)
  }
}
