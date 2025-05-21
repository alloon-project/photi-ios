//
//  RecommendedChallengesViewModel.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift

protocol RecommendedChallengesCoordinatable: AnyObject { }

protocol RecommendedChallengesViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: RecommendedChallengesCoordinatable? { get set }
}

final class RecommendedChallengesViewModel: RecommendedChallengesViewModelType {
  weak var coordinator: RecommendedChallengesCoordinatable?
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
