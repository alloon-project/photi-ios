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
  func mapToChallengeSummaryFromMyChallenge(dto: [MyChallengeResponseDTO]) -> [ChallengeSummary]
  func mapToChallengeSummaryFromSearchChallenge(dto: [SearchChallengeResponseDTO]) -> [ChallengeSummary]
  func mapToChallengeSummaryFromByName(_ dto: [SearchChallengeByNameResponseDTO]) -> [ChallengeSummary]
  func mapToChallengeSummaryFromByHashTag(_ dto: [SearchChallengeByHashtagResponseDTO]) -> [ChallengeSummary]
  func mapToFeed(dto: FeedResponseDTO) -> Feed
  func mapToFeed(dto: FeedDetailResponseDTO, id: Int) -> Feed
  func mapToFeedComment(dto: FeedCommentResponseDTO) -> FeedComment
  func mapToChallengeDescription(dto: ChallengeDescriptionResponseDTO, id: Int) -> ChallengeDescription
  func mapToChallengeMembers(dto: [ChallengeMemberResponseDTO]) -> [ChallengeMember]
}

public struct ChallengeDataMapperImpl: ChallengeDataMapper {
  public init() { }
}

// MARK: - Challenge Mapping
public extension ChallengeDataMapperImpl {
  func mapToChallengeDetail(dto: PopularChallengeResponseDTO) -> ChallengeDetail {
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
      memberImages: memberImages.compactMap { URL(string: $0 ?? "") }
    )
  }
  
  func mapToChallengeDetail(dto: ChallengeDetailResponseDTO, id: Int) -> ChallengeDetail {
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
      memberImages: memberImages.compactMap { URL(string: $0 ?? "") },
      isPublic: dto.isPublic,
      rules: rules,
      creator: dto.creator
    )
  }
  
  func mapToChallengeSummaryFromMyChallenge(dto: [MyChallengeResponseDTO]) -> [ChallengeSummary] {
    return dto.map {
      let endDate = $0.endDate.toDate() ?? Date()
      let hasTags = $0.hashtags.map { $0.hashtag }
      let proveTime = $0.proveTime.toDate("HH:mm") ?? Date()
      let imageUrl = URL(string: $0.challengeImageUrl ?? "")
      let feedImageUrl = URL(string: $0.feedImageUrl ?? "")
      
      return .init(
        id: $0.id,
        name: $0.name,
        imageUrl: imageUrl,
        endDate: endDate,
        hashTags: hasTags,
        proveTime: proveTime,
        feedImageURL: feedImageUrl,
        feedId: $0.feedId,
        isProve: $0.isProve
      )
    }
  }
  
  func mapToChallengeSummaryFromSearchChallenge(dto: [SearchChallengeResponseDTO]) -> [ChallengeSummary] {
    return dto.map {
      let endDate = $0.endDate.toDate() ?? Date()
      let hasTags = $0.hashtags.map { $0.hashtag }
      let imageUrl = URL(string: $0.imageUrl ?? "")
      
      return .init(
        id: $0.id,
        name: $0.name,
        imageUrl: imageUrl,
        endDate: endDate,
        hashTags: hasTags
      )
    }
  }
  
  func mapToChallengeSummaryFromByName(_ dto: [SearchChallengeByNameResponseDTO]) -> [ChallengeSummary] {
    return dto.map {
      let imageUrl = URL(string: $0.imageUrl ?? "")
      let endDate = $0.endDate.toDate() ?? Date()
      let memberImages = $0.memberImages.map { $0.memberImage }
      
      return .init(
        id: $0.id,
        name: $0.name,
        imageUrl: imageUrl,
        endDate: endDate,
        hashTags: [],
        memberCount: $0.currentMemberCnt,
        memberImages: memberImages.compactMap { URL(string: $0 ?? "") }
      )
    }
  }
  
  func mapToChallengeSummaryFromByHashTag(_ dto: [SearchChallengeByHashtagResponseDTO]) -> [ChallengeSummary] {
    return dto.map {
      let imageUrl = URL(string: $0.imageUrl ?? "")
      let endDate = $0.endDate.toDate() ?? Date()
      let hashTags = $0.hashtags.map { $0.hashtag }
      let memberImages = $0.memberImages.map { $0.memberImage }
      
      return .init(
        id: $0.id,
        name: $0.name,
        imageUrl: imageUrl,
        endDate: endDate,
        hashTags: hashTags,
        memberCount: $0.currentMemberCnt,
        memberImages: memberImages.compactMap { URL(string: $0 ?? "") }
      )
    }
  }
  
  func mapToChallengeDescription(dto: ChallengeDescriptionResponseDTO, id: Int) -> ChallengeDescription {
    let proveTime = dto.proveTime.toDate("HH:mm") ?? Date()
    let startDate = dto.startDate.toDate() ?? Date()
    let endDate = dto.endDate.toDate() ?? Date()
    let rules = dto.rules.map { $0.rule }
    return .init(
      id: id,
      rules: rules,
      proveTime: proveTime,
      startDate: startDate,
      goal: dto.goal,
      endDate: endDate
    )
  }
  
  func mapToChallengeMembers(dto: [ChallengeMemberResponseDTO]) -> [ChallengeMember] {
    return dto.map {
      return .init(
        id: $0.id,
        name: $0.username,
        imageUrl: URL(string: $0.imageUrl ?? ""),
        isOwner: $0.isCreator,
        duration: $0.duration,
        goal: $0.goal ?? ""
      )
    }
  }
}

// MARK: - Feed Mapping
public extension ChallengeDataMapperImpl {
  func mapToFeed(dto: FeedResponseDTO) -> Feed {
    let updateTime = dto.createdDateTime.toDateFromISO8601() ?? Date()
    let imageUrl = URL(string: dto.imageUrl ?? "") ?? defaultURL()
    return .init(
      id: dto.id,
      author: dto.username,
      imageURL: imageUrl,
      isLike: dto.isLike,
      updateTime: updateTime
    )
  }
  
  func mapToFeed(dto: FeedDetailResponseDTO, id: Int) -> Feed {
    let updateTime = dto.createdDateTime.toDateFromISO8601() ?? Date()
    let imageURL = URL(string: dto.feedImageUrl ?? "") ?? defaultURL()
    let authorImageURL = URL(string: dto.userImageUrl ?? "")
    
    return .init(
      id: id,
      author: dto.username,
      imageURL: imageURL,
      authorImageURL: authorImageURL,
      updateTime: updateTime,
      likeCount: dto.likeCnt,
      isLike: dto.isLike
    )
  }
  
  func mapToFeedComment(dto: FeedCommentResponseDTO) -> FeedComment {
    return .init(
      id: dto.id,
      author: dto.username,
      comment: dto.comment
    )
  }
}

// MARK: - Private Methods
private extension ChallengeDataMapperImpl {
  func defaultURL() -> URL {
    return URL(string: "")!
  }
}
