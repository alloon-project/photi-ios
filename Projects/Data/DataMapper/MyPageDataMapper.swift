//
//  MyPageDataMapper.swift
//  Data
//
//  Created by 임우섭 on 11/3/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import Entity

public protocol MyPageDataMapper {
  func mapToMyPageSummary(from dto: UserChallengeHistoryResponseDTO) -> MyPageSummary
  func mapToDate(from dto: VerifiedChallengeDatesResponseDTO) -> [Date]
  func mapToFeedHistory(dtos: [FeedHistoryResponseDTO]) -> [FeedSummary]
  func mapToChallengeSummaryFromEnded(dto: [EndedChallengeResponseDTO]) -> [ChallengeSummary]
  func mapToFeedSummaryFromFeedsByDate(dtos: [FeedByDateResponseDTO]) -> [FeedSummary]
  func mapToUserProfile(dto: UserProfileResponseDTO) -> UserProfile
  func mapToChangePasswordRequestDTO(password: String, newPassword: String) -> ChangePasswordRequestDTO
}

public struct MyPageDataMapperImpl: MyPageDataMapper {
  public init() { }
}

public extension MyPageDataMapperImpl {
  func mapToMyPageSummary(from dto: UserChallengeHistoryResponseDTO) -> MyPageSummary {
    return MyPageSummary(
      userName: dto.username,
      imageUrl: imageURL(from: dto.imageUrl),
      feedCnt: dto.feedCnt,
      endedChallengeCnt: dto.endedChallengeCnt,
      registerDate: dto.registerDate.toDate("yyyy-MM-dd") ?? Date()
    )
  }
  
  func mapToDate(from dto: VerifiedChallengeDatesResponseDTO) -> [Date] {
    return dto.list.compactMap { $0.toDate("yyyy-MM-dd") }
  }
  
  func mapToFeedHistory(dtos: [FeedHistoryResponseDTO]) -> [FeedSummary] {
    return dtos.map {
      .init(
        feedId: $0.feedId,
        challengeId: $0.challengeId,
        imageUrl: imageURL(from: $0.imageUrl),
        createdDate: $0.createdDate.toDate("yyyy-MM-dd") ?? Date(),
        invitationCode: $0.invitationCode,
        name: $0.name,
        isDeleted: $0.isDeleted
      )
    }
  }
  
  func mapToChallengeSummaryFromEnded(dto: [EndedChallengeResponseDTO]) -> [ChallengeSummary] {
    return dto.map {
      let endDate = $0.endDate.toDate() ?? Date()
      let memberImages = $0.memberImages.map { $0.memberImage }
      
      return .init(
        id: $0.id,
        name: $0.name,
        imageUrl: imageURL(from: $0.imageUrl),
        endDate: endDate,
        hashTags: [],
        memberCount: $0.currentMemberCnt,
        memberImages: memberImages.compactMap { URL(string: $0 ?? "") }
      )
    }
  }
  
  func mapToFeedSummaryFromFeedsByDate(dtos: [FeedByDateResponseDTO]) -> [FeedSummary] {
    return dtos.map {
      let proveTime = $0.proveTime.toDate("HH:mm") ?? Date()

      return .init(
        feedId: $0.feedId,
        challengeId: $0.challengeId,
        imageUrl: imageURL(from: $0.imageUrl),
        proveTime: proveTime,
        name: $0.name
      )
    }
  }
  
  func mapToUserProfile(dto: UserProfileResponseDTO) -> UserProfile {
    return .init(
      imageUrl: imageURL(from: dto.imageUrl),
      name: dto.username,
      email: dto.email
    )
  }
  
  func mapToChangePasswordRequestDTO(password: String, newPassword: String) -> ChangePasswordRequestDTO {
    return ChangePasswordRequestDTO(
      password: password,
      newPassword: newPassword,
      newPasswordReEnter: newPassword
    )
  }
}

// MARK: - Private Methods
private extension MyPageDataMapperImpl {
  func imageURL(from strURL: String?) -> URL? {
    guard let strURL else { return nil }
    return URL(string: strURL)
  }
}
