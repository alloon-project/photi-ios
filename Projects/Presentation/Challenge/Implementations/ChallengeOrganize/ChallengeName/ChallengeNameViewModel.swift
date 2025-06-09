//
//  ChallengeNameViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import UseCase

protocol ChallengeNameCoordinatable: AnyObject {
  func didTapBackButtonAtChallengeName()
  func attachChallengeGoal(challengeName: String, isPublic: Bool)
}

protocol ChallengeNameViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChallengeNameCoordinatable? { get set }
}

final class ChallengeNameViewModel: ChallengeNameViewModelType {
  let disposeBag = DisposeBag()
  private let mode: ChallengeOrganizeMode
  private let useCase: OrganizeUseCase
  
  weak var coordinator: ChallengeNameCoordinatable?
    
  // MARK: - Input
  struct Input {
    var didTapBackButton: ControlEvent<Void>
    var challengeName: ControlProperty<String>
    var isPublicChallenge: Observable<Bool>
    var didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {}
  
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
        owner.coordinator?.didTapBackButtonAtChallengeName()
      }
      .disposed(by: disposeBag)
  
    input.didTapNextButton
      .withLatestFrom(
        Observable.combineLatest(input.challengeName, input.isPublicChallenge)
        )
      .bind(with: self) { owner, pieceOfChallenge in
        owner.coordinator?.attachChallengeGoal(
          challengeName: pieceOfChallenge.0,
          isPublic: pieceOfChallenge.1
        )
        Task {
          await owner.useCase.configureChallengePayload(.name, value: pieceOfChallenge.0)
          await owner.useCase.configureChallengePayload(.isPublic, value: pieceOfChallenge.1)
        }
      }
      .disposed(by: disposeBag)
    
    return Output()
  }
}
