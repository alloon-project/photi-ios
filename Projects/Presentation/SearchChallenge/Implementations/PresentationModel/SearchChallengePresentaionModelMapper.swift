//
//  SearchChallengePresentaionModelMapper.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import CoreUI
import Entity

struct SearchChallengePresentaionModelMapper {
  func mapToChallengeCardFromDetail(_ challenge: ChallengeDetail) -> ChallengeCardPresentationModel {
    return .init(
      id: challenge.id,
      hashTags: challenge.hashTags,
      title: challenge.name,
      imageUrl: challenge.imageUrl,
      deadLine: challenge.endDate.toString("~ yyyy.MM.dd")
    )
  }
  
  func mapToChallengeCardFromSummary(_ challenge: ChallengeSummary) -> ChallengeCardPresentationModel {
    return .init(
      id: challenge.id,
      hashTags: challenge.hashTags,
      title: challenge.name,
      imageUrl: challenge.imageUrl,
      deadLine: challenge.endDate.toString("~ yyyy.MM.dd")
    )
  }
  
  func mapToResultChallengeCardFromSummary(_ challenge: ChallengeSummary) -> ResultChallengeCardPresentationModel {
    return .init(
      id: challenge.id,
      hashTags: challenge.hashTags,
      title: challenge.name,
      imageUrl: challenge.imageUrl,
      deadLine: challenge.endDate.toString("yyyy. MM. dd 종료"),
      memberCount: challenge.memberCount ?? 0,
      memberImageUrls: challenge.memberImages ?? []
    )
  }
}
