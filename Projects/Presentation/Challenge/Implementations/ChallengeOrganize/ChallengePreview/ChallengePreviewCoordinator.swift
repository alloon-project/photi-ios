//
//  ChallengePreviewCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import Core

protocol ChallengePreviewListener: AnyObject {
  func didTapBackButtonAtChallengePreview()
  func didFinishOrganizeChallenge(challengeId: Int)
}

protocol ChallengePreviewPresentable {
  func setLeftView(
    title: String,
    hashtags: [String],
    verificationTime: String,
    goal: String
  )
  
  func setRightView(
    image: UIImageWrapper,
    rules: [String],
    deadLine: String
  )
}

final class ChallengePreviewCoordinator: ViewableCoordinator<ChallengePreviewPresentable> {
  weak var listener: ChallengePreviewListener?
  private let viewPresentationModel: PreviewPresentationModel
  
  private let viewModel: ChallengePreviewViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengePreviewViewModel,
    viewPresentationModel: PreviewPresentationModel
  ) {
    self.viewModel = viewModel
    self.viewPresentationModel = viewPresentationModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    presenter.setLeftView(
      title: viewPresentationModel.title,
      hashtags: viewPresentationModel.hashtags,
      verificationTime: viewPresentationModel.verificationTime,
      goal: viewPresentationModel.goal
    )
    presenter.setRightView(
      image: viewPresentationModel.image,
      rules: viewPresentationModel.rules,
      deadLine: viewPresentationModel.deadLine
    )
  }
}

extension ChallengePreviewCoordinator: ChallengePreviewCoordinatable {
  func didFinishOrganizeChallenge(challengeId: Int) {
    listener?.didFinishOrganizeChallenge(challengeId: challengeId)
  }
  
  func didTapBackButtonAtPreview() {
    listener?.didTapBackButtonAtChallengePreview()
  }
}
