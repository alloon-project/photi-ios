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
  func mapToChallengeDetail(dto: ChallengeDetailResponseDTO, id: Int) -> ChallengeDetail
  func mapToChallengeSummary(dto: EndedChallengeResponseDTO) -> [ChallengeSummary]
  func mapToFeed(dto: FeedResponseDTO) -> Feed
  func mapToFeed(dto: FeedDetailResponseDTO, id: Int) -> Feed
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
  
  public func mapToChallengeDetail(dto: ChallengeDetailResponseDTO, id: Int) -> ChallengeDetail {
    let endDate = dto.endDate.toDate() ?? Date()
    let hasTags = dto.hashtags.map { $0.hashtag }
    let proveTime = dto.proveTime.toDate("HH:mm") ?? Date()
    let memberImages = dto.memberImages.map { $0.memberImage }
    let rules = dto.rules.map { $0.rule }
    
    return .init(
      id: id,
      name: dto.name,
      imageUrl: dto.imageUrl,
      endDate: endDate,
      hashTags: hasTags,
      proveTime: proveTime,
      goal: dto.goal,
      memberCount: dto.currentMemberCnt,
      memberImages: memberImages,
      isPublic: dto.isPublic,
      rules: rules
    )
  }
  
  public func mapToChallengeSummary(dto: EndedChallengeResponseDTO) -> [ChallengeSummary] {
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
  
  public func mapToFeed(dto: FeedResponseDTO) -> Feed {
    let updateTime = dto.createdDateTime.toDateFromISO8601() ?? Date()
    return .init(
      id: dto.id,
      author: dto.username,
      imageURL: dto.imageUrl,
      isLike: dto.isLike,
      updateTime: updateTime
    )
  }
  
  public func mapToFeed(dto: FeedDetailResponseDTO, id: Int) -> Feed {
    let updateTime = dto.createdDateTime.toDateFromISO8601() ?? Date()
    return .init(
      id: id,
      author: dto.username,
      imageURL: dto.feedImageUrl,
      authorImageURL: dto.userImageUrl,
      updateTime: updateTime,
      likeCount: dto.likeCnt
    )
  }
}
