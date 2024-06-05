//
//  EnterIdViewModel.swift
//  LogInImpl
//
//  Created by jung on 6/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol EnterIdCoordinatable: AnyObject { 
  func didTapBackButton()
  func didTapNextButton()
}

protocol EnterIdViewModelType: AnyObject, EnterIdViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EnterIdCoordinatable? { get set }
}

final class EnterIdViewModel: EnterIdViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: EnterIdCoordinatable?
  
  private let inValidIdFormRelay = PublishRelay<Void>()
  private let duplicateIdRelay = PublishRelay<Void>()
  private let validIdRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input { 
    var didTapBackButton: ControlEvent<Void>
    var didTapNextButton: ControlEvent<Void>
    var didTapVerifyIdButton: ControlEvent<Void>
    var userId: ControlProperty<String>
  }
  
  // MARK: - Output
  struct Output { 
    var inValidIdForm: Signal<Void>
    var duplicateId: Signal<Void>
    var validId: Signal<Void>
    var isDuplicateButtonEnabled: Signal<Bool>
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .subscribe(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapNextButton
      .subscribe(with: self) { owner, _ in
        owner.coordinator?.didTapNextButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapVerifyIdButton
      .withLatestFrom(input.userId)
      .subscribe(with: self) { owner, userId in
        owner.isDuplicated(userId)
      }
      .disposed(by: disposeBag)
    
    return Output(
      inValidIdForm: inValidIdFormRelay.asSignal(),
      duplicateId: duplicateIdRelay.asSignal(),
      validId: validIdRelay.asSignal(),
      isDuplicateButtonEnabled: input.userId.map { !$0.isEmpty }.asSignal(onErrorJustReturn: false)
    )
  }
}

// MARK: - Private Methods
private extension EnterIdViewModel {
  func isDuplicated(_ id: String) {
    guard id.isValidateId else {
      inValidIdFormRelay.accept(())
      return
    }
    
    // TODO: - API 연결시 구현 예정
  }
}
