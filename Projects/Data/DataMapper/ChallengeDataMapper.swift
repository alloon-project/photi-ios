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
  func mapToChallengeDetail(dto: PopularChallengeResponseDTO) -> ChallengeDetail
  func mapToChallengeSummary(dto: EndedChallengeResponseDTO) -> [ChallengeSummary]
}

public struct ChallengeDataMapperImpl: ChallengeDataMapper {
  public init() {}
  
  public func mapToChallengeDetail(dto: PopularChallengeResponseDTO) -> ChallengeDetail {
    let endDate = dto.endDate.toDate() ?? Date()
    let hasTags = dto.hashtags.map { $0.hashtag }
    let proveTime = dto.proveTime.toDate("HH:mm") ?? Date()
    let memberImages = dto.memberImages.map { $0.memberImage }
    
    return .init(
      id: dto.id,
      name: dto.name,
      imageUrl: dto.imageUrl,
      endDate: endDate,
      hashTags: hasTags,
      proveTime: proveTime,
      goal: dto.goal,
      memberCount: dto.currentMemberCnt,
      memberImages: memberImages
    )
  }
  
  public func mapToChallengeSummary(dto: EndedChallengeResponseDTO) -> [ChallengeSummary] {
    let contents = dto.content
    
    return dto.content.map {
      let endDate = $0.endDate.toDate() ?? Date()
      let memberImages = $0.memberImages.map { $0.memberImage }
      
      return .init(
        id: $0.id,
        name: $0.name,
        imageUrl: $0.imageUrl,
        endDate: endDate,
        hashTags: [],
        memberCount: $0.currentMemberCnt,
        memberImages: memberImages
      )
    }
  }
}
