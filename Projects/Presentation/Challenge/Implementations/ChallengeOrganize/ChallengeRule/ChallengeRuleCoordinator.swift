//
//  ChallengeRuleCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core

protocol ChallengeRuleListener: AnyObject {
  func didTapBackButtonAtChallengeRule()
  func didFinishChallengeRules(challengeRules: [String])
}

protocol ChallengeRulePresentable { }

final class ChallengeRuleCoordinator: ViewableCoordinator<ChallengeRulePresentable> {
  weak var listener: ChallengeRuleListener?
  
  private let viewModel: ChallengeRuleViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeRuleViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

extension ChallengeRuleCoordinator: ChallengeRuleCoordinatable {
  func didFinishAtChallengeRule(challengeRules: [String]) {
    listener?.didFinishChallengeRules(challengeRules: challengeRules)
  }
  
  func didTapBackButtonAtChallengeRule() {
    listener?.didTapBackButtonAtChallengeRule()
  }
}
