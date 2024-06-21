//
//  TempPasswordViewModel.swift
//  LogInImpl
//
//  Created by wooseob on 6/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import DesignSystem

protocol TempPasswordCoordinatable: AnyObject {
  // viewModel에서 coordinator로 전달할 이벤트들을 정의합니다.
  func didTapBackButton()
  func didTapContinueButton()
}

protocol TempPasswordViewModelType: TempPasswordViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: TempPasswordCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class TempPasswordViewModel: TempPasswordViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: TempPasswordCoordinatable?
  
  // MARK: - Input
  struct Input {
    var password: ControlProperty<String>
    var didTapBackButton: ControlEvent<Void>
    var didTapResendButton: ControlEvent<Void>
    var didTapContinueButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    var isEnabledNextButton: Driver<Bool>
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.disposed(by: disposeBag)
    
    // TODO: 재전송 API
    
    input.didTapContinueButton
      .bind(with: self) { owner, _ in
        // 임시 비밀번호 확인 API
        owner.coordinator?.didTapContinueButton()
      }.disposed(by: disposeBag)
    
    let isEnabledNextButton = input.password
      .map { !$0.isEmpty }
    
    return Output(
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false)
    )
  }
}
