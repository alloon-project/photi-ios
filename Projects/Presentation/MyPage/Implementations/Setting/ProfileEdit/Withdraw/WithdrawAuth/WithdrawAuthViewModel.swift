//
//  WithdrawAuthViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 2/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol WithdrawAuthCoordinatable: AnyObject {
  func withdrawalSucceed()
  func didTapBackButton()
  func authenticatedFailed()
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
  private let didFailPasswordVerificationRelay = PublishRelay<Void>()
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let password: ControlProperty<String>
    let didTapWithdrawButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let didFailPasswordVerification: Signal<Void>
    let networkUnstable: Signal<Void>
    let isEnabledWithdrawButton: Driver<Bool>
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
  @MainActor func withdraw(password: String) async {
    do {
      try await useCase.withdraw(with: password)
      coordinator?.withdrawalSucceed()
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.accept(()) }
    
    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .myPageFailed(reason) where reason == .passwordMatchInvalid:
        didFailPasswordVerificationRelay.accept(())
      case let .myPageFailed(reason) where reason == .userNotFound:
        coordinator?.authenticatedFailed()
      default:
        networkUnstableRelay.accept(())
    }
  }
}
