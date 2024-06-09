//
//  EnterEmailViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol EnterEmailCoordinatable: AnyObject {
  func attachVerifyEmail(userEmail: String)
  func didTapBackButton()
}

protocol EnterEmailViewModelType: AnyObject, EnterEmailViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EnterEmailCoordinatable? { get set }
}

final class EnterEmailViewModel: EnterEmailViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: EnterEmailCoordinatable?
  
  // MARK: - Input
  struct Input {
    var didTapBackButton: ControlEvent<Void>
    var didTapNextButton: ControlEvent<Void>
    var userEmail: ControlProperty<String>
    var endEditingUserEmail: ControlEvent<Void>
    var editingUserEmail: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    var isValidEmailForm: Signal<Bool>
    var isOverMaximumText: Signal<Bool>
    var isEnabledNextButton: Signal<Bool>
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapNextButton
      .withLatestFrom(input.userEmail)
      .bind(with: self) { owner, email in
        owner.coordinator?.attachVerifyEmail(userEmail: email)
      }
      .disposed(by: disposeBag)
    
    let isValidEmailForm = input.endEditingUserEmail
      .withLatestFrom(input.userEmail)
      .withUnretained(self)
      .filter { $0.1.count <= 100 && !$0.1.isEmpty }
      .map { $0.0.isValidEmailForm($0.1) }
      
    let isOverMaximumText = input.editingUserEmail
      .withLatestFrom(input.userEmail)
      .map { $0.count > 100 }
    
    let isEnabledConfirm = input.userEmail
      .withUnretained(self)
      .map { $0.0.isValidEmailForm($0.1) && $0.1.count <= 100 }
    
    return Output(
      isValidEmailForm: isValidEmailForm.asSignal(onErrorJustReturn: false),
      isOverMaximumText: isOverMaximumText.asSignal(onErrorJustReturn: true), 
      isEnabledNextButton: isEnabledConfirm.asSignal(onErrorJustReturn: false)
    )
  }
}

// MARK: - Private Methods
private extension EnterEmailViewModel {
  func isValidEmailForm(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    return  NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
  }
}
