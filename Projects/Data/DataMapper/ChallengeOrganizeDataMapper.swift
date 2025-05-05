//
//  ChallengeOrganizeDataMapper.swift
//  Data
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import DTO
import Entity

public protocol ChallengeOrganizeDataMapper {
  func mapToSampleImages(dto: ChallengeSampleImageResponseDTO) -> [String]
  func mapToOrganizedChallenge(payload: ChallengeOrganizePayload)
  -> ChallengeOrganizeRequestDTO
}

public struct ChallengeOrganizeDataMapperImpl: ChallengeOrganizeDataMapper {
  public init() {}
  
  public func mapToSampleImages(dto: ChallengeSampleImageResponseDTO) -> [String] {
    return dto.list.map { $0 }
  }
  
  public func mapToOrganizedChallenge(payload: ChallengeOrganizePayload)
  -> ChallengeOrganizeRequestDTO {
    return ChallengeOrganizeRequestDTO(
      name: payload.name,
      isPublic: payload.isPublic,
      goal: payload.goal,
      proveTime: payload.proveTime,
      endDate: payload.endDate,
      rules: payload.rules,
      hashtags: payload.hashtags,
      image: payload.image,
      imageType: payload.imageType
    )
  }
}
