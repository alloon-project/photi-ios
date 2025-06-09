//
//  ChallengeModifyViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 5/17/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Entity
import UseCase

protocol ChallengeModifyCoordinatable: AnyObject {
  func attachModifyName()
  func attachModifyGoal()
  func attachModifyCover()
  func attachModifyHashtag()
  func attachModifyRule()
  func didTapBackButton()
}

protocol ChallengeModifyViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ChallengeModifyCoordinatable? { get set }
}

final class ChallengeModifyViewModel: ChallengeModifyViewModelType {
  weak var coordinator: ChallengeModifyCoordinatable?
  private let disposeBag = DisposeBag()
  private let challengeId: Int
  private let useCase: OrganizeUseCase
  
  private let networkUnstableRelay = PublishRelay<Void>()
  private let emptyFileErrorRelay = PublishRelay<String>()
  private let imageTypeErrorRelay = PublishRelay<String>()
  private let fileTooLargeErrorRelay = PublishRelay<String>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapChallengeName: Signal<Void>
    let didTapChallengeHashtag: Signal<Void>
    let didTapChallengeGoal: Signal<Void>
    let didTapChallengeCover: Signal<Void>
    let didTapChallengeRule: Signal<Void>
    let didTapModifyButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let networkUnstable: Signal<Void>
    let emptyFileError: Signal<String>
    let imageTypeError: Signal<String>
    let fileTooLargeError: Signal<String>
  }
  
  // MARK: - Initializers
  init(
    useCase: OrganizeUseCase,
    challengeId: Int
  ) {
    self.useCase = useCase
    self.challengeId = challengeId
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapChallengeName
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachModifyName()
      }.disposed(by: disposeBag)
    
    input.didTapChallengeHashtag
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachModifyHashtag()
      }.disposed(by: disposeBag)
    
    input.didTapChallengeGoal
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachModifyGoal()
      }.disposed(by: disposeBag)
    
    input.didTapChallengeCover
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachModifyCover()
      }.disposed(by: disposeBag)
    
    input.didTapChallengeRule
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachModifyRule()
      }.disposed(by: disposeBag)
    
    input.didTapModifyButton
      .bind(with: self) { owner, _ in
        owner.modifyChallenge()
      }.disposed(by: disposeBag)
    
    return Output(
      networkUnstable: networkUnstableRelay.asSignal(),
      emptyFileError: emptyFileErrorRelay.asSignal(),
      imageTypeError: imageTypeErrorRelay.asSignal(),
      fileTooLargeError: fileTooLargeErrorRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension ChallengeModifyViewModel {
  func modifyChallenge() {
    // TODO: - Challenge 수정 API 호출
  }
}
