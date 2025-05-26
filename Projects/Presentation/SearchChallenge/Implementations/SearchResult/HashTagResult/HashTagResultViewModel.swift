//
//  HashTagResultViewModel.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift

protocol HashTagResultCoordinatable: AnyObject { }

protocol HashTagResultViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: HashTagResultCoordinatable? { get set }
}

final class HashTagResultViewModel: HashTagResultViewModelType {
  weak var coordinator: HashTagResultCoordinatable?
  private let disposeBag = DisposeBag()

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
