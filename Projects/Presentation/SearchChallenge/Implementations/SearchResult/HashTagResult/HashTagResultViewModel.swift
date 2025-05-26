//
//  HashTagResultViewModel.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
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
  private let searchInput: Driver<String>

  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init(searchInput: Driver<String>) {
    self.searchInput = searchInput
  }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}
