//
//  ChallengeOrganizeRepository.swift
//  Domain
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity

public protocol ChallengeOrganizeRepository {
  func fetchChallengeSampleImage() -> Single<[String]>
  func challengeOrganize(payload: ChallengeOrganizePayload) -> Single<ChallengeDetail>
  func challengeModify(payload: ChallengeModifyPayload, challengeId: Int) -> Single<Void>
}
