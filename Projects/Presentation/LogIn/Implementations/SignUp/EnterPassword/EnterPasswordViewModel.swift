//
//  EnterPasswordViewModel.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol EnterPasswordCoordinatable: AnyObject { }

protocol EnterPasswordViewModelType: AnyObject, EnterPasswordViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EnterPasswordCoordinatable? { get set }
}

final class EnterPasswordViewModel: EnterPasswordViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: EnterPasswordCoordinatable?
  
  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}
