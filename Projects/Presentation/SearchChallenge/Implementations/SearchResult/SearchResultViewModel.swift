//
//  SearchResultViewModel.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift

protocol SearchResultCoordinatable: AnyObject { }

protocol SearchResultViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: SearchResultCoordinatable? { get set }
}

final class SearchResultViewModel: SearchResultViewModelType {
  weak var coordinator: SearchResultCoordinatable?
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
