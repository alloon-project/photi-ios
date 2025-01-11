//
//  FindIdViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol FindIdCoordinatable: AnyObject {
  // viewModel에서 coordinator로 전달할 이벤트들을 정의합니다.
  func isRequestSucceed()
  func didTapBackButton()
}

protocol FindIdViewModelType: AnyObject, FindIdViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: FindIdCoordinatable? { get set }
}

final class FindIdViewModel: FindIdViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: FindIdCoordinatable?
  
  private let useCase: FindIdUseCase
  private let checkedEmailRelay = PublishRelay<Void>()
  private let wrongEmailRelay = PublishRelay<Void>()
  private let requestFailedRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let email: ControlProperty<String>
    let endEditingUserEmail: ControlEvent<Void>
    let editingUserEmail: ControlEvent<Void>
    let didTapNextButton: ControlEvent<Void>
    let didAppearAlert: PublishRelay<Void>
  }
  
  // MARK: - Output
  struct Output {
    var isValidateEmail: Signal<Bool>
    var isOverMaximumText: Signal<Bool>
    var checkEmailSucceed: Signal<Void>
    var wrongEmail: Signal<Void>
    var requestFailed: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: FindIdUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    // 단순 동작 bind
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    let isValidateEmail = input.endEditingUserEmail
      .withLatestFrom(input.email)
      .filter { $0.count <= 100 && !$0.isEmpty }
      .map { $0.isValidateEmail() }
      .asSignal(onErrorJustReturn: false)
    
    let isOverMaximumText = input.editingUserEmail
      .withLatestFrom(input.email)
      .map { $0.count > 100 }
    
    input.didTapNextButton
      .withLatestFrom(input.email)
      .bind(with: self) { owner, email in
        owner.requestCheckEmail(email: email)
      }.disposed(by: disposeBag)
    
    input.didAppearAlert
      .bind(with: self) { owner, _ in
        owner.coordinator?.isRequestSucceed()
      }.disposed(by: disposeBag)
    
    return Output(
      isValidateEmail: isValidateEmail,
      isOverMaximumText: isOverMaximumText.asSignal(onErrorJustReturn: true),
      checkEmailSucceed: checkedEmailRelay.asSignal(),
      wrongEmail: wrongEmailRelay.asSignal(),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension FindIdViewModel {
  func requestCheckEmail(email: String) {
    useCase.findId(userEmail: email)
      .subscribe(
        with: self,
        onSuccess: { owner, _ in
          owner.checkedEmailRelay.accept(())
        },
        onFailure: { owner, error in
          print(error)
          owner.requestFailed(error: error)
        }
      )
      .disposed(by: disposeBag)
  }
  
  func requestFailed(error: Error) {
    if
      let error = error as? APIError,
      case .userNotFound = error {
      wrongEmailRelay.accept(())
    } else {
      requestFailedRelay.accept(())
    }
  }
}
