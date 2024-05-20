//
//  LogInViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxSwift

protocol LogInCoordinatable { }

// Input, Output ViewModel
protocol LogInViewModelType: LogInViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
}

class LogInViewModel: LogInViewModelType {
  let disposeBag = DisposeBag()
  
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
