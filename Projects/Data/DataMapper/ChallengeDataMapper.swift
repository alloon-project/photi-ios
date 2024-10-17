//
//  ChallengeDataMapper.swift
//  DTO
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import DTO
import Core
import Entity

public protocol ChallengeDataMapper {
  func mapToChallenge(dto: ChallengeResponseDTO) -> Challenge
}

public struct ChallengeDataMapperImpl: ChallengeDataMapper {
  public init() {}
  
  public func mapToChallenge(dto: ChallengeResponseDTO) -> Challenge {
    let endDate = dto.endDate.toDate() ?? Date()
    let proveTime = dto.proveTime.toDate("HH:mm") ?? Date()
    let hasTags = dto.hashtags.map { $0.hashtag }
    
    return .init(
      id: dto.id,
      name: dto.name,
      imageURL: dto.imageUrl,
      goal: dto.goal,
      proveTime: proveTime,
      endDate: endDate,
      hashTags: hasTags
    )
  }
}
