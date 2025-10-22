//
//  ChallengeOrganizeRepository.swift
//  Domain
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Entity

public protocol ChallengeOrganizeRepository {
  func fetchChallengeSampleImage() async throws -> [String]
  func challengeOrganize(payload: ChallengeOrganizePayload) async throws -> ChallengeDetail
  func challengeModify(payload: ChallengeModifyPayload, challengeId: Int) async throws
}
