//
//  FindIdViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import DesignSystem

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
    var didSendInformation: Signal<Void>
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    // 단순 동작 bind
    input.didTapBackButton
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.didTapBackButton()
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
    
    let source = input.didTapNextButton
      .withLatestFrom(input.email)
      .withUnretained(self)
      .map { $0.0.requestCheckEmail(email: $0.1) }
      .asSignal(onErrorJustReturn: ())
      
    input.didAppearAlert
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.isRequestSucceed()
      }.disposed(by: disposeBag)
    // Output 반환
    return Output(isValidateEmail: isValidateEmail,
                  isOverMaximumText: isOverMaximumText.asSignal(onErrorJustReturn: true),
                  didSendInformation: source) // TODO: 서버 연결 후 수정
  }
}

// MARK: - Private Methods
private extension FindIdViewModel {
  // TODO: - 서버 연결 후 수정
  func requestCheckEmail(email: String) {
    // API 요청 응답 메시지 나타내줘야하면
  }
}
