//
//  VerifyEmailViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol VerifyEmailCoordinatable: AnyObject { 
  func didTapBackButton()
}

protocol VerifyEmailViewModelType: AnyObject, VerifyEmailViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: VerifyEmailCoordinatable? { get set }
}

final class VerifyEmailViewModel: VerifyEmailViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: VerifyEmailCoordinatable?
  
  // MARK: - Input
  struct Input { 
    var didTapBackButton: ControlEvent<Void>
    var didTapResendButton: ControlEvent<Void>
    var didTapNextButton: ControlEvent<Void>
    var verifyCode: ControlProperty<String>
  }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    return Output()
  }
}
