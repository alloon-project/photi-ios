//
//  OrganizeUseCase.swift
//  Domain
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Entity

public protocol OrganizeUseCase {
  func configureChallengePayload(_ type: PayloadType)
  func fetchChallengeSampleImages() async throws -> [String]
  func organizeChallenge() async throws -> ChallengeDetail
  func modifyChallenge() async throws
  func setChallengeId(id: Int)
}
