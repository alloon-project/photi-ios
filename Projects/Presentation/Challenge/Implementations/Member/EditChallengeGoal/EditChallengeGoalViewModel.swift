//
//  EditChallengeGoalViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift

protocol EditChallengeGoalCoordinatable: AnyObject { }

protocol EditChallengeGoalViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: EditChallengeGoalCoordinatable? { get set }
}

final class EditChallengeGoalViewModel: EditChallengeGoalViewModelType {
  weak var coordinator: EditChallengeGoalCoordinatable?
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
