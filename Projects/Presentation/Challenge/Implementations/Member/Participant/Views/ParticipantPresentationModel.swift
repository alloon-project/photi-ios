//
//  ParticipantPresentationModel.swift
//  ChallengeImpl
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

struct ParticipantPresentationModel {
  let userName: String
  let avatarURL: URL?
  let duration: String
  let goal: String
  let isChallengeOwner: Bool
  let isSelf: Bool
}
