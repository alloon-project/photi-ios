//
//  EnterIdViewModel.swift
//  LogInImpl
//
//  Created by jung on 6/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol EnterIdCoordinatable: AnyObject { }

protocol EnterIdViewModelType: AnyObject, EnterIdViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: EnterIdCoordinatable? { get set }
}

final class EnterIdViewModel: EnterIdViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: EnterIdCoordinatable?
  
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
