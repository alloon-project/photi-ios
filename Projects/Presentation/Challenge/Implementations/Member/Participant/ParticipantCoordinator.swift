//
//  ParticipantCoordinator.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ParticipantListener: AnyObject {
  func didChangeContentOffsetAtParticipant(_ offset: Double)
  func didTapEditButton(userID: Int, challengeID: Int)
}

protocol ParticipantPresentable { }

final class ParticipantCoordinator: ViewableCoordinator<ParticipantPresentable> {
  weak var listener: ParticipantListener?

  private let viewModel: ParticipantViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ParticipantViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - ParticipantCoordinatable
extension ParticipantCoordinator: ParticipantCoordinatable {
  func didChangeContentOffset(_ offset: Double) {
    listener?.didChangeContentOffsetAtParticipant(offset)
  }
  
  func didTapEditButton(userID: Int, challengeID: Int) {
    listener?.didTapEditButton(userID: userID, challengeID: challengeID)
  }
}
