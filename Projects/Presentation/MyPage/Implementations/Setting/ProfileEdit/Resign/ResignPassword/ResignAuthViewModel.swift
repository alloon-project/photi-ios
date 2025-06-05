//
//  ResignAuthViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 2/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol ResignAuthCoordinatable: AnyObject {
  func isRequestSucceed()
  func didTapBackButton()
}

protocol ResignAuthViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ResignAuthCoordinatable? { get set }
}

final class ResignAuthViewModel: ResignAuthViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: ResignAuthCoordinatable?
  
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
    
    input.didTapNextButton
      .withLatestFrom(input.password)
      .bind(with: self) { owner, password in
        owner.requestCheckPassword(password: password)
      }.disposed(by: disposeBag)
    
    // Output 반환
    return Output(
      wrongPassword: wrongPasswordRelay.asSignal(),
      requestFailed: requestFailedRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension ResignAuthViewModel {
  func requestCheckPassword(password: String) { }
  
  func requestFailed(error: Error) { }
}
