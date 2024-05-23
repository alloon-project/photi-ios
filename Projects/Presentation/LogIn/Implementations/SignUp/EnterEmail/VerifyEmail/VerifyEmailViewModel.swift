//
//  VerifyEmailViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxSwift

protocol VerifyEmailCoordinatable: AnyObject { }

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
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}
