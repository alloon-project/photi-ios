//
//  EnterPasswordViewModel.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol EnterPasswordCoordinatable: AnyObject { }

protocol EnterPasswordViewModelType: AnyObject, EnterPasswordViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EnterPasswordCoordinatable? { get set }
}

final class EnterPasswordViewModel: EnterPasswordViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: EnterPasswordCoordinatable?
  
  // MARK: - Input
  struct Input {
    var password: ControlProperty<String>
    var reEnteredPassword: ControlProperty<String>
    var didTapBackButton: ControlEvent<Void>
    var didTapContinueButton: ControlEvent<Void>
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
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
//        owner?.coordinator
      }
      .disposed(by: disposeBag)
    
    input.didTapContinueButton
      .bind(with: self) { owner, _ in
        print("continue")
      }
      .disposed(by: disposeBag)
    
    let containAlphabet = input.password
      .map { $0.contain("[a-zA-Z]") }
    
    let containNumber = input.password
      .map { $0.contain("[0-9]") }
    
    let containSpecial = input.password
      .map { $0.contain("[^a-zA-Z0-9]") }
    
    let isValidRange = input.password
      .map { $0.count >= 8 && $0.count <= 30 }
    
    let isValidPassword = Observable.combineLatest(
      containAlphabet, containNumber, containSpecial, isValidRange
    ) { $0 && $1 && $2 && $3 }
    
    let correspondPassword = Observable.combineLatest(
      input.password, input.reEnteredPassword
    ) { $0 == $1 }
    
    let isEnabledNextButton = Observable.combineLatest(
      isValidPassword, correspondPassword
    ) { $0 && $1 }
    
    return Output(
      containAlphabet: containAlphabet.asDriver(onErrorJustReturn: false),
      containNumber: containNumber.asDriver(onErrorJustReturn: false),
      containSpecial: containSpecial.asDriver(onErrorJustReturn: false),
      isValidRange: isValidRange.asDriver(onErrorJustReturn: false),
      isValidPassword: isValidPassword.asDriver(onErrorJustReturn: false), 
      correspondPassword: correspondPassword.asDriver(onErrorJustReturn: false),
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false)
    )
  }
}
