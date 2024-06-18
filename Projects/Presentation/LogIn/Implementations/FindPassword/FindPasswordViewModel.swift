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

protocol FindPasswordCoordinatable: AnyObject {
  func didTapBackButton()
  func attachTempPassword(userEmail: String)
}

protocol FindPasswordViewModelType: FindPasswordViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
}

final class FindPasswordViewModel: FindPasswordViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: FindPasswordCoordinatable?
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
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.didTapBackButton()
      }.disposed(by: disposeBag)
    
    input.didTapNextButton // TODO: - 이메일 & 아이디 확인 로직필요
      .withLatestFrom(input.userEmail)
      .bind(with: self) { onwer, email in
        onwer.coordinator?.attachTempPassword(userEmail: email) // 입력받은값으로변경
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
    
    let idWithEmailValid = Observable.combineLatest(input.userId, input.userEmail)
    
    let isEnabledConfirm = idWithEmailValid
      .map { $0.0.isValidateId && $0.1.isValidateEmail() }
      
    return Output(
      isVaildId: isValidId.asSignal(onErrorJustReturn: false), 
      isValidEmailForm: isValidEmailForm.asSignal(onErrorJustReturn: false),
      isOverMaximumText: isOverMaximumText.asSignal(onErrorJustReturn: true),
      isEnabledNextButton: isEnabledConfirm.asSignal(onErrorJustReturn: false))
  }
}

// MARK: - Private Methods
private extension FindPasswordViewModel {
  // TODO: 서버 연결 시 아이디 & 이메일 확인 로직 구현

}
