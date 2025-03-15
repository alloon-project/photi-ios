//
//  FeedDataMapper.swift
//  Data
//
//  Created by 임우섭 on 2/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import DTO
import Core
import Entity

public protocol FeedDataMapper {
  func mapToFeedHistory(dto: FeedHistoryResponseDTO) -> [FeedHistory]
}

public struct FeedDataMapperImpl: FeedDataMapper {
  public init() {}
  
  public func mapToFeedHistory(dto: FeedHistoryResponseDTO) -> [FeedHistory] {
    return dto.content.map {
      FeedHistory(
        feedId: $0.feedId,
        challengeId: $0.challengeId,
        imageUrl: $0.imageUrl,
        provedDate: $0.createDate,
        name: $0.name
      )
    }
  }
}
