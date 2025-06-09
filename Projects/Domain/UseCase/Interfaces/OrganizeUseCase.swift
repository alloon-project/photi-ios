//
//  OrganizeUseCase.swift
//  Domain
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity

public enum PayloadType {
  case name
  case isPublic
  case goal
  case proveTime
  case endDate
  case rules
  case hashtags
  case image
  case imageType
}

public protocol OrganizeUseCase {
  func configureChallengePayload(_ type: PayloadType, value: Any) async
  func fetchChallengeSampleImages() -> Single<[String]>
  func organizeChallenge() -> Single<ChallengeDetail>
  func modifyChallenge() -> Single<Void>
  func setChallengeId(id: Int)
}
