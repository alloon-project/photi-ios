//
//  SearchChallengePresentaionModelMapper.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import Entity

struct SearchChallengePresentaionModelMapper {
  func mapToChallengeCardPresentationModel(from challenge: ChallengeDetail) -> ChallengeCardPresentationModel {
    return .init(
      id: challenge.id,
      hashTags: challenge.hashTags,
      title: challenge.name,
      imageUrl: challenge.imageUrl,
      deadLine: challenge.endDate.toString("~ yyyy.MM.dd")
    )
  }
  
  func mapToPresentationModelChallengeSummary(from challenge: ChallengeSummary) -> ChallengeCardPresentationModel {
    return .init(
      id: challenge.id,
      hashTags: challenge.hashTags,
      title: challenge.name,
      imageUrl: challenge.imageUrl,
      deadLine: challenge.endDate.toString("~ yyyy.MM.dd")
    )
  }
}
