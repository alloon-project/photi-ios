//
//  OrganizeUseCase.swift
//  Domain
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Entity

public enum ImageChange {
  case keep            // 기존 이미지 유지
  case replace(data: Data, type: String)  // 새 이미지로 교체
}

public protocol OrganizeUseCase {
  func configureChallengePayload(_ type: PayloadType)
  func fetchChallengeSampleImages() async throws -> [String]
  func organizeChallenge() async throws -> ChallengeDetail
  func modifyChallenge(id: Int, payload: ChallengeModifyPayload, imageChange: ImageChange) async throws
  func setChallengeId(id: Int)
}
