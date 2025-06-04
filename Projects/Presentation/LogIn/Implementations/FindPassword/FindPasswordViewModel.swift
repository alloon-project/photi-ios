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
  private let invalidIdOrEmailRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let userId: ControlProperty<String>
    let endEditingUserId: ControlEvent<Void>
    let editingUserId: ControlEvent<Void>
    let userEmail: ControlProperty<String>
    let endEditingUserEmail: ControlEvent<Void>
    let editingUserEmail: ControlEvent<Void>
    let didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output { 
    var isVaildId: Signal<Bool>
    var isValidEmailForm: Signal<Bool>
    var isOverMaximumText: Signal<Bool>
    var isEnabledNextButton: Signal<Bool>
    var invalidIdOrEmail: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: LogInUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.didTapBackButton()
      }.disposed(by: disposeBag)
    
    let isValidId = input.endEditingUserId
      .withLatestFrom(input.userId)
      .withUnretained(self)
      .map { $0.1.isValidateId }
    
    let isValidEmailForm = input.endEditingUserEmail
      .withLatestFrom(input.userEmail)
      .withUnretained(self)
      .filter { $0.1.count <= 100 && !$0.1.isEmpty }
      .map { $0.1.isValidateEmail() }
      
    let isOverMaximumText = input.editingUserEmail
      .withLatestFrom(input.userEmail)
      .map { $0.count > 100 }
    
    let idWithEmailValid = Observable.combineLatest(input.userEmail, input.userId)
    
    let isEnabledConfirm = idWithEmailValid
      .map { $0.0.isValidateEmail() && $0.1.isValidateId }
    
    let didTapNextButtonWithInfo = input.didTapNextButton
      .withLatestFrom(idWithEmailValid)
      .share()
    
    didTapNextButtonWithInfo
      .filter { !$0.0.isEmpty && !$0.1.isEmpty }
      .subscribe(with: self) { owner, info in
        owner.findPassword(userEmail: info.0, userName: info.1)
      }
      .disposed(by: disposeBag)
    
    return Output(
      isVaildId: isValidId.asSignal(onErrorJustReturn: false), 
      isValidEmailForm: isValidEmailForm.asSignal(onErrorJustReturn: false),
      isOverMaximumText: isOverMaximumText.asSignal(onErrorJustReturn: true),
      isEnabledNextButton: isEnabledConfirm.asSignal(onErrorJustReturn: false),
      invalidIdOrEmail: invalidIdOrEmailRelay.asSignal()
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
