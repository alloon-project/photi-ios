//
//  FeedsByDateViewModel.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift

protocol FeedsByDateCoordinatable: AnyObject { }

protocol FeedsByDateViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FeedsByDateCoordinatable? { get set }
}

final class FeedsByDateViewModel: FeedsByDateViewModelType {
  weak var coordinator: FeedsByDateCoordinatable?
  private let disposeBag = DisposeBag()
  let date: Date

  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init(date: Date) {
    self.date = date
  }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}
