//
//  EditChallengeGoalViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol EditChallengeGoalCoordinatable: AnyObject {
  func didTapBackButton()
  func didChangeChallengeGoal(_ goal: String)
}

protocol EditChallengeGoalViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: EditChallengeGoalCoordinatable? { get set }
}

final class EditChallengeGoalViewModel: EditChallengeGoalViewModelType {
  weak var coordinator: EditChallengeGoalCoordinatable?
  private let disposeBag = DisposeBag()

  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let goalText: ControlProperty<String>
    let didTapSaveButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let saveButtonisEnabled: Driver<Bool>
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapSaveButton
      .withLatestFrom(input.goalText)
      .bind(with: self) { owner, text in
        owner.coordinator?.didChangeChallengeGoal(text)
      }
      .disposed(by: disposeBag)
    
    return Output(
      saveButtonisEnabled: input.goalText.map { !$0.isEmpty }.asDriver(onErrorJustReturn: false)
    )
  }
}
