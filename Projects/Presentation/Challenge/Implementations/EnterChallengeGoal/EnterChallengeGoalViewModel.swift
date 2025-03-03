//
//  EnterChallengeGoalViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol EnterChallengeGoalCoordinatable: AnyObject {
  func didTapBackButton()
  func didChangeChallengeGoal()
  func didSkipEnterChallengeGoal()
  func requestLogin()
}

protocol EnterChallengeGoalViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: EnterChallengeGoalCoordinatable? { get set }
}

final class EnterChallengeGoalViewModel: EnterChallengeGoalViewModelType {
  weak var coordinator: EnterChallengeGoalCoordinatable?
  private let disposeBag = DisposeBag()
  private let useCase: ChallengeUseCase
  private let challengeID: Int
  
  private let networkUnstableRelay = PublishRelay<Void>()
  private let loginTriggerRelay = PublishRelay<Void>()

  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let goalText: ControlProperty<String>
    let didTapSaveButton: ControlEvent<Void>
    let didTapSkipButton: Signal<Void>
    let didTapLoginButton: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let saveButtonisEnabled: Driver<Bool>
    let networkUnstable: Signal<Void>
    let loginTrigger: Signal<Void>
  }
  
  // MARK: - Initializers
  init(challengeID: Int, useCase: ChallengeUseCase) {
    self.challengeID = challengeID
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapSaveButton
      .withLatestFrom(input.goalText)
      .bind(with: self) { owner, goal in
        Task { await owner.updateChallengeGoal(goal) }
      }
      .disposed(by: disposeBag)
    
    input.didTapSkipButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.didSkipEnterChallengeGoal()
      }
      .disposed(by: disposeBag)
    
    input.didTapLoginButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.requestLogin()
      }
      .disposed(by: disposeBag)
    
    return Output(
      saveButtonisEnabled: input.goalText.map { !$0.isEmpty }.asDriver(onErrorJustReturn: false),
      networkUnstable: networkUnstableRelay.asSignal(),
      loginTrigger: loginTriggerRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension EnterChallengeGoalViewModel {
  func updateChallengeGoal(_ goal: String) async {
    do {
      try await useCase.updateChallengeGoal(goal, challengeId: challengeID).value
      coordinator?.didChangeChallengeGoal()
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.accept(()) }
    
    switch error {
      case .authenticationFailed: loginTriggerRelay.accept(())
      default: networkUnstableRelay.accept(())
    }
  }
}
