//
//  WithdrawAuthViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 2/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol WithdrawAuthCoordinatable: AnyObject {
  func isRequestSucceed()
  func didTapBackButton()
}

protocol WithdrawAuthViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: WithdrawAuthCoordinatable? { get set }
}

final class WithdrawAuthViewModel: WithdrawAuthViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: WithdrawAuthCoordinatable?
  
  private let useCase: ProfileEditUseCase
  private let wrongPasswordRelay = PublishRelay<Void>()
  private let requestFailedRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let password: ControlProperty<String>
    let didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    var wrongPassword: Signal<Void>
    var requestFailed: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: ProfileEditUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    let isEnabledWithdrawButton = input.password.map { $0.isValidPassword }
    
    input.didTapWithdrawButton
      .withLatestFrom(input.password)
      .bind(with: self) { owner, password in
        Task { await owner.withdraw(password: password) }
      }
      .disposed(by: disposeBag)
    
    return Output(
      didFailPasswordVerification: didFailPasswordVerificationRelay.asSignal(),
      networkUnstable: networkUnstableRelay.asSignal(),
      isEnabledWithdrawButton: isEnabledWithdrawButton.asDriver(onErrorJustReturn: false)
    )
  }
}

// MARK: - API Methods
private extension WithdrawAuthViewModel {
  func requestCheckPassword(password: String) { }
  
  func requestFailed(error: Error) { }
}
