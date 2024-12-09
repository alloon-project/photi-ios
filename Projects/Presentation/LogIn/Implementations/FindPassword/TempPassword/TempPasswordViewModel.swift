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
import Entity
import UseCase

protocol TempPasswordCoordinatable: AnyObject {
  // viewModel에서 coordinator로 전달할 이벤트들을 정의합니다.
  func didTapBackButton()
  func attachNewPassword()
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
  private let findPasswordUseCase: FindPasswordUseCase
  private let loginUseCase: LogInUseCase
  private let email: String
  private let name: String
  
  weak var coordinator: TempPasswordCoordinatable?
  
  private let emailResentRelay = PublishRelay<Void>()
  private let invalidPasswordRelay = PublishRelay<Void>()

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
    var isEmailResendSucceed: Signal<Void>
  }
  
  // MARK: - Initializers
  init(
    findPasswordUseCase: FindPasswordUseCase,
    loginUseCase: LogInUseCase,
    email: String,
    name: String
  ) {
    self.findPasswordUseCase = findPasswordUseCase
    self.loginUseCase = loginUseCase
    self.email = email
    self.name = name
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.disposed(by: disposeBag)
    
    input.didTapResendButton
      .bind(with: self) { owner, _ in
        owner.findPassword(userEmail: owner.email, userName: owner.name)
      }.disposed(by: disposeBag)
    
    input.didTapContinueButton
      .withLatestFrom(input.password)
      .bind(with: self) { owner, password in
        owner.requestLogin(userName: owner.name, password: password)
      }.disposed(by: disposeBag)
    
    let isEnabledNextButton = input.password
      .map { !$0.isEmpty }
    
    return Output(
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false),
      isEmailResendSucceed: emailResentRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension TempPasswordViewModel {
  // TODO: 서버 연결 시 아이디 & 이메일 확인 로직 구현
  func findPassword(userEmail: String, userName: String) {
    findPasswordUseCase.findPassword(userEmail: userEmail, userName: userName)
      .subscribe(
        with: self,
        onSuccess: { onwer, _ in
          onwer.emailResentRelay.accept(())
        },
        onFailure: { _, err in
          print(err)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func requestLogin(userName: String, password: String) {
    loginUseCase.login(username: userName, password: password)
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { owner, _ in
          owner.coordinator?.attachNewPassword()
        },
        onFailure: { owner, error in
          owner.requestFailed(with: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func requestFailed(with error: Error) {
    if let error = error as? APIError, case .loginFailed = error {
      invalidPasswordRelay.accept(())
    }
  }
}
