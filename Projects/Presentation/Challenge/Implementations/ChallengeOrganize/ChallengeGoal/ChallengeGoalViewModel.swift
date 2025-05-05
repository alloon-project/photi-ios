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
    var proveTime: Observable<String>
    var date: Observable<Date>
    var didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    var isEnabledNextButton: Driver<Bool>
  }
  
  // MARK: - Initializers
  init() {}
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtChallengeGoal()
      }
      .disposed(by: disposeBag)
  
    let infos = Observable.combineLatest(
      input.challengeGoal,
      input.proveTime,
      input.date
    )
    
    input.didTapNextButton
      .withLatestFrom(infos)
      .bind(with: self) { owner, infos in
        owner.coordinator?.didFinishChallengeGoal(
          challengeGoal: infos.0,
          proveTime: infos.1,
          endDate: infos.2
        )
      }
      .disposed(by: disposeBag)
    
    let isEnabledNextButton = Observable.combineLatest(
      input.challengeGoal.asObservable(),
      input.proveTime.asObservable(),
      input.date) { goal, time, date in
        !goal.isEmpty && !time.isEmpty && date > Date()
      }
    
    return Output(
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false)
    )
  }
}
