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
  func didFinishEnteringGoal(_ goal: String)
  func authenticatedFailed()
}

protocol EnterChallengeGoalViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: EnterChallengeGoalCoordinatable? { get set }
}

final class EnterChallengeGoalViewModel: EnterChallengeGoalViewModelType {
  weak var coordinator: EnterChallengeGoalCoordinatable?
  private let disposeBag = DisposeBag()
  private let mode: ChallengeGoalMode
  private let useCase: ChallengeUseCase
  private let challengeID: Int
  
  private let networkUnstableRelay = PublishRelay<Void>()
  private let alreadyJoinedRelay = PublishRelay<Void>()
  
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
    let networkUnstable: Signal<Void>
    let alreadyJoined: Signal<Void>
  }
  
  // MARK: - Initializers
  init(
    mode: ChallengeGoalMode,
    challengeID: Int,
    useCase: ChallengeUseCase
  ) {
    self.mode = mode
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
        Task { await owner.handleGoalSubmission(goal) }
      }
      .disposed(by: disposeBag)
    
    input.didTapSkipButton
      .emit(with: self) { owner, _ in
        Task { await owner.handleSkipEnteredGoal() }
      }
      .disposed(by: disposeBag)

    return Output(
      saveButtonisEnabled: input.goalText.map { !$0.isEmpty }.asDriver(onErrorJustReturn: false),
      networkUnstable: networkUnstableRelay.asSignal(),
      alreadyJoined: alreadyJoinedRelay.asSignal()
    )
  }
}

// MARK: - API Methods
private extension EnterChallengeGoalViewModel {
  func handleGoalSubmission(_ goal: String) async {
    switch mode {
    case .join:
      await joinChallenge(goal: goal)
    case .edit:
      await updateChallengeGoal(goal)
    }
  }
  
  func handleSkipEnteredGoal() async {
    if case .join = mode {
      await joinChallenge(goal: "")
    }
  }
  
  @MainActor func joinChallenge(goal: String) async {
    do {
      try await useCase.joinChallenge(id: challengeID, goal: goal).value
      coordinator?.didFinishEnteringGoal(goal)
    } catch {
      requestFailed(with: error)
    }
  }
  
  @MainActor func updateChallengeGoal(_ goal: String) async {
    do {
      try await useCase.updateChallengeGoal(goal, challengeId: challengeID).value
      coordinator?.didFinishEnteringGoal(goal)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.accept(()) }
    
    switch error {
      case let .challengeFailed(reason) where reason == .alreadyJoinedChallenge:
        alreadyJoinedRelay.accept(())

      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      default:
        networkUnstableRelay.accept(())
    }
  }
}
