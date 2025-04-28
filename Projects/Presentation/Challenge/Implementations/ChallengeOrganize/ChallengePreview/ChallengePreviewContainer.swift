//
//  ChallengePreviewContainer.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengePreviewDependency: Dependency {
}

protocol ChallengePreviewContainable: Containable {
  func coordinator(
    listener: ChallengePreviewListener,
    viewPresentationModel: PreviewPresentationModel
  ) -> ViewableCoordinating
}

final class ChallengePreviewContainer: Container<ChallengePreviewDependency>, ChallengePreviewContainable {
  func coordinator(
    listener: ChallengePreviewListener,
    viewPresentationModel: PreviewPresentationModel
  ) -> ViewableCoordinating {
    let viewModel = ChallengePreviewViewModel()
    let viewControllerable = ChallengePreviewViewController(viewModel: viewModel)
    
    let coordinator = ChallengePreviewCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      viewPresentationModel: viewPresentationModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
