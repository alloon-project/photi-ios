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
    
  private let isRuleSelected = BehaviorRelay<Bool>(value: false)
  // MARK: - Input
  struct Input {
    var didTapBackButton: ControlEvent<Void>
    var challengeRules: Signal<[String]>
    var didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let isRuleSelected: Driver<Bool>
  }
  
  // MARK: - Initializers
  init() {}
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtChallengeRule()
      }
      .disposed(by: disposeBag)
    
    input.challengeRules
      .asObservable()
      .map { rules in
        let hasAtLeastOne = !rules.isEmpty
        let underLimit = rules.count <= 5
        return hasAtLeastOne && underLimit
      }
      .bind(with: self, onNext: { owner, isSelected in
        owner.isRuleSelected.accept(isSelected)
      })
      .disposed(by: disposeBag)
    
    input.didTapNextButton
      .withLatestFrom(input.challengeRules)
      .bind(with: self) { owner, rules in
        owner.coordinator?.didFinishAtChallengeRule(challengeRules: rules)
      }
      .disposed(by: disposeBag)
    
    return Output(
      isRuleSelected: isRuleSelected.asDriver(onErrorJustReturn: false)
    )
  }
}
