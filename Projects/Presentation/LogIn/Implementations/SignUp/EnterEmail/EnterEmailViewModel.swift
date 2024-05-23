//
//  EnterEmailViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol EnterEmailCoordinatable: AnyObject {
  func attachVerifyEmail(userEmail: String)
  func detachVerifyEmail()
  func didTapBackButton()
}

protocol EnterEmailViewModelType: AnyObject, EnterEmailViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EnterEmailCoordinatable? { get set }
}

final class EnterEmailViewModel: EnterEmailViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: EnterEmailCoordinatable?
  
  // MARK: - Input
  struct Input {
    var didTapBackButton: ControlEvent<Void>
    var didTapNextButton: ControlEvent<Void>
    var userEmail: ControlProperty<String>
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
    
    input.didTapNextButton
      .withLatestFrom(input.userEmail)
      .bind(with: self) { owner, email in
        owner.coordinator?.attachVerifyEmail(userEmail: email)
      }
      .disposed(by: disposeBag)
    
    return Output()
  }
}
