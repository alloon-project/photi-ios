//
//  ChallengeOrganizeDataMapper.swift
//  Data
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import DTO
import Entity

public protocol ChallengeOrganizeDataMapper {
  func mapToOrganizedChallenge(payload: ChallengeOrganizePayload) -> ChallengeOrganizeRequestDTO?
  func mapToModifyChallenge(payload: ChallengeModifyPayload) -> ChallengeModifyRequestDTO?
  func mapToChallengeDetail(dto: ChallengeOrganizeResponseDTO) -> ChallengeDetail
}

public struct ChallengeOrganizeDataMapperImpl: ChallengeOrganizeDataMapper {
  public init() {}
  
  public func mapToOrganizedChallenge(payload: ChallengeOrganizePayload) -> ChallengeOrganizeRequestDTO? {
    guard let jsonString = payload.toJSONString() else { return nil }
    return ChallengeOrganizeRequestDTO(
      jsonString: jsonString,
      image: payload.image,
      imageType: payload.imageType
    )
  }
  
  public func mapToModifyChallenge(payload: ChallengeModifyPayload) -> ChallengeModifyRequestDTO? {
    guard let jsonString = payload.toJSONString() else { return nil }
    return ChallengeModifyRequestDTO(
      jsonString: jsonString,
      image: payload.image,
      imageType: payload.imageType
    )
  }
  
  public func mapToChallengeDetail(dto: ChallengeOrganizeResponseDTO) -> ChallengeDetail {
    let endDate = dto.endDate.toDate() ?? Date()
    let hasTags = dto.hashtags.map { $0.hashtag }
    let proveTime = dto.proveTime.toDate("HH:mm") ?? Date()
    let rules = dto.rules.map { $0.rule }
    
    return ChallengeDetail(
      id: dto.id,
      name: dto.name,
      imageUrl: URL(string: dto.imageUrl),
      endDate: endDate,
      hashTags: hasTags,
      proveTime: proveTime,
      goal: dto.goal,
      memberCount: 0,
      memberImages: [],
      isPublic: nil,
      rules: rules)
  }
}
