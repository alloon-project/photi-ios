//
//  RecentChallengesViewModel.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift

protocol RecentChallengesCoordinatable: AnyObject { }

protocol RecentChallengesViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: RecentChallengesCoordinatable? { get set }
}

final class RecentChallengesViewModel: RecentChallengesViewModelType {
  weak var coordinator: RecentChallengesCoordinatable?
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
