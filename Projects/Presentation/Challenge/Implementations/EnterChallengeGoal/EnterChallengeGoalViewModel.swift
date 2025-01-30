//
//  EnterChallengeGoalViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol EnterChallengeGoalCoordinatable: AnyObject {
  func didTapBackButton()
  func didChangeChallengeGoal()
}

protocol EnterChallengeGoalViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: EnterChallengeGoalCoordinatable? { get set }
}

final class EnterChallengeGoalViewModel: EnterChallengeGoalViewModelType {
  weak var coordinator: EnterChallengeGoalCoordinatable?
  private let disposeBag = DisposeBag()
  private let challengeID: Int

  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let goalText: ControlProperty<String>
    let didTapSaveButton: ControlEvent<Void>
    let didTapSkipButton: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let saveButtonisEnabled: Driver<Bool>
  }
  
  // MARK: - Initializers
  init(challengeID: Int) {
    self.challengeID = challengeID
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    Observable.merge(
      input.didTapSaveButton.asObservable(),
      input.didTapSkipButton.asObservable()
    )
      .bind(with: self) { owner, _ in
        owner.coordinator?.didChangeChallengeGoal()
      }
      .disposed(by: disposeBag)
    
    return Output(
      saveButtonisEnabled: input.goalText.map { !$0.isEmpty }.asDriver(onErrorJustReturn: false)
    )
  }
}
