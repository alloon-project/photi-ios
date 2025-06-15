//
//  OrganizeUseCase.swift
//  Domain
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity

public protocol OrganizeUseCase {
  func configureChallengePayload(_ type: PayloadType)
  func fetchChallengeSampleImages() -> Single<[String]>
  func organizeChallenge() -> Single<ChallengeDetail>
  func modifyChallenge() -> Single<Void>
  func setChallengeId(id: Int)
}
