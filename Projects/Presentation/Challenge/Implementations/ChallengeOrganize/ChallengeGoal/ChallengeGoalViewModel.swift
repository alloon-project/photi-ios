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
  func didFinishChallengeGoal(challengeGoal: String, proveTime: String, endDate: String)
}

protocol ChallengeGoalViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChallengeGoalCoordinatable? { get set }
}

final class ChallengeGoalViewModel: ChallengeGoalViewModelType {
  let disposeBag = DisposeBag()
  private let mode: ChallengeOrganizeMode
  private let useCase: OrganizeUseCase
  
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
  init(
    mode: ChallengeOrganizeMode,
    useCase: OrganizeUseCase
  ) {
    self.mode = mode
    self.useCase = useCase
  }
  
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
          endDate: infos.2.toString("YYYY-MM-dd")
        )
        owner.useCase.configureChallengePayload(.goal(infos.0))
        owner.useCase.configureChallengePayload(.proveTime(infos.1))
        owner.useCase.configureChallengePayload(.endDate(infos.2.toString("YYYY-MM-dd")))
      }
      .disposed(by: disposeBag)
    
    let isEnabledNextButton = Observable.combineLatest(
        input.challengeGoal.asObservable(),
        input.proveTime.asObservable(),
        input.date
    ) { goal, time, date in
        let trimmedGoal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        let isValidGoal = !trimmedGoal.isEmpty && trimmedGoal.count >= 10
        let isValidTime = !time.isEmpty
        let isValidDate = date > Date()

        return isValidGoal && isValidTime && isValidDate
    }
    
    return Output(
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false)
    )
  }
}
