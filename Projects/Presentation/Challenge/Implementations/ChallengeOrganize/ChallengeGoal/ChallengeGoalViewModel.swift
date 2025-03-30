//
//  ChallengeGoalViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UseCase

protocol ChallengeGoalCoordinatable: AnyObject {
  func didTapBackButtonAtChallengeGoal()
  func didFinishChallengeGoal(challengeGoal: String, proveTime: String, endDate: Date)
}

protocol ChallengeGoalViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChallengeGoalCoordinatable? { get set }
}

final class ChallengeGoalViewModel: ChallengeGoalViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: ChallengeGoalCoordinatable?
    
  // MARK: - Input
  struct Input {
    var didTapBackButton: ControlEvent<Void>
    var challengeGoal: ControlProperty<String>
    var isPublicChallenge: Observable<Bool>
    var didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {}
  
  // MARK: - Initializers
  init() {}
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtChallengeGoal()
      }
      .disposed(by: disposeBag)
  
    return Output()
  }
}
