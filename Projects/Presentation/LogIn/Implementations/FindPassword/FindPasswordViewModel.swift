//
//  FindPasswordViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol FindPasswordCoordinatable { }

protocol FindPasswordViewModelType: FindPasswordViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
}

final class FindPasswordViewModel: FindPasswordViewModelType {
  let disposeBag = DisposeBag()
  
  // MARK: - Input
  struct Input {
    let userId: ControlProperty<String>
    let email: ControlProperty<String>
    let didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}
