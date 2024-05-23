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
  func attachVerifyEmail()
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
