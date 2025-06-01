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
}

public struct MyPageDataMapperImpl: MyPageDataMapper {
  public init() { }
  
  public func mapToMyPageSummary(from dto: UserChallengeHistoryResponseDTO) -> MyPageSummary {
    return MyPageSummary(
      userName: dto.username,
      imageUrl: imageURL(from: dto.imageUrl),
      feedCnt: dto.feedCnt,
      endedChallengeCnt: dto.endedChallengeCnt,
      registerDate: dto.registerDate.toDate("yyyy-MM-dd") ?? Date()
    )
  }
// MARK: - Private Methods
private extension MyPageDataMapperImpl {
  func imageURL(from strURL: String?) -> URL? {
    guard let strURL else { return nil }
    return URL(string: strURL)
  }
}
