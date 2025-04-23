//
//  ChallengeRuleViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import UseCase

protocol ChallengeRuleCoordinatable: AnyObject {
  func didTapBackButtonAtChallengeRule()
  func didFinishAtChallengeRule(challengeRules: [String])
}

protocol ChallengeRuleViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChallengeRuleCoordinatable? { get set }
}

final class ChallengeRuleViewModel: ChallengeRuleViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: ChallengeRuleCoordinatable?
    
  // MARK: - Input
  struct Input {
    var didTapBackButton: ControlEvent<Void>
    var challengeRules: Signal<[String]>
    var didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {}
  
  // MARK: - Initializers
  init() {}
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtChallengeRule()
      }
      .disposed(by: disposeBag)
    
    input.didTapNextButton
      .withLatestFrom(input.challengeRules)
      .bind(with: self) { owner, rules in
        owner.coordinator?.didFinishAtChallengeRule(challengeRules: rules)
      }
      .disposed(by: disposeBag)
    
    return Output()
  }
}
