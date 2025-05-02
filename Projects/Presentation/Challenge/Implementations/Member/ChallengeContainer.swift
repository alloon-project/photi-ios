//
//  ChallengeContainer.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Challenge
import Core
import LogIn
import Report
import UseCase

public protocol ChallengeDependency: Dependency {
  var reportContainable: ReportContainable { get }
  var loginContainable: LogInContainable { get }
  var challengeUseCase: ChallengeUseCase { get }
  var feedUseCase: FeedUseCase { get }
}

public final class ChallengeContainer:
  Container<ChallengeDependency>,
  ChallengeContainable,
  FeedDependency,
  DescriptionDependency,
  ParticipantDependency {
  public func coordinator(
    listener: ChallengeListener,
    challengeId: Int,
    presentType: ChallengePresentType
  ) -> ViewableCoordinating {
    let viewModel = ChallengeViewModel(useCase: dependency.challengeUseCase, challengeId: challengeId)
    let viewControllerable = ChallengeViewController(viewModel: viewModel)
    
    let feedContainer = FeedContainer(dependency: self)
    let descriptionContainer = DescriptionContainer(dependency: self)
    let participantContainer = ParticipantContainer(dependency: self)
    
    let coordinator = ChallengeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      initialPresentType: presentType,
      feedContainer: feedContainer,
      descriptionContainer: descriptionContainer,
      participantContainer: participantContainer,
      logInContainer: dependency.loginContainable,
      reportContainer: dependency.reportContainable
    )
    coordinator.listener = listener
    return coordinator
  }
  
  var challengeUseCase: ChallengeUseCase { dependency.challengeUseCase }
  var feedUseCase: FeedUseCase { dependency.feedUseCase }
}
