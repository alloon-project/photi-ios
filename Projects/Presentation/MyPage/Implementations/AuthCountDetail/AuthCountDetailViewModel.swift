//
//  AuthCountDetailViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 8/26/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol AuthCountDetailCoordinatable: AnyObject { }

protocol AuthCountDetailViewModelType: AnyObject, AuthCountDetailViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: AuthCountDetailCoordinatable? { get set }
}

final class AuthCountDetailViewModel: AuthCountDetailViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: AuthCountDetailCoordinatable?
  
  // MARK: - Input
  struct Input {}
  
  // MARK: - Output
  struct Output {}
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}

