//
//  PasswordChangeViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import DesignSystem

protocol PasswordChangeCoordinatable: AnyObject {
  func didTapBackButton()
  func didTapChangePasswordAlert()
}

protocol PasswordChangeViewModelType: PasswordChangeViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: PasswordChangeCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class PasswordChangeViewModel: PasswordChangeViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: PasswordChangeCoordinatable?
  
  // MARK: - Input
  struct Input {
    var currentPassrod: ControlProperty<String>
    var newPassword: ControlProperty<String>
    var reEnteredPassword: ControlProperty<String>
    var didTapBackButton: ControlEvent<Void>
    var didTapContinueButton: ControlEvent<Void>
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
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapContinueButton
      .bind(with: self) { owner, _ in
        // TODO: 비밀번호 재설정 API
        owner.coordinator?.didTapChangePasswordAlert()
      }
      .disposed(by: disposeBag)
    
    let containAlphabet = input.newPassword
      .map { $0.contain("[a-zA-Z]") }
    
    let containNumber = input.newPassword
      .map { $0.contain("[0-9]") }
    
    let containSpecial = input.newPassword
      .map { $0.contain("[^a-zA-Z0-9]") }
    
    let isValidRange = input.newPassword
      .map { $0.count >= 8 && $0.count <= 30 }
    
    let isValidPassword = Observable.combineLatest(
      containAlphabet, containNumber, containSpecial, isValidRange
    ) { $0 && $1 && $2 && $3 }
    
    let correspondPassword = Observable.combineLatest(
      input.newPassword, input.reEnteredPassword
    ) { $0 == $1 }
    
    let isEnabledNextButton = Observable.combineLatest(
      isValidPassword, correspondPassword
    ) { $0 && $1 }
    
    // TODO: 비밀번호 재설정 요청 -> 성공시 팝업 팝업 끝나면 로그인으로 이동
    
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
