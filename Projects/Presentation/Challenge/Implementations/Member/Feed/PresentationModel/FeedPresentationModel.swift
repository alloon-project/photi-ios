//
//  FeedPresentationModel.swift
//  ChallengeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Entity

struct FeedPresentationModel: Hashable {
  let id: Int
  let imageURL: URL
  let userName: String
  let updateTime: String 
  let isLike: Bool
}

enum FeedsAlignMode: String, CaseIterable {
  case recent = "최신순"
  case popular = "인기순"
  
  var toOrderType: ChallengeFeedsOrderType {
    switch self {
      case .recent: return .recent
      case .popular: return .popular
    }
  }
}

enum ProveType: Equatable {
  case didProof
  case didNotProof(String)
  
  var toString: String {
    switch self {
      case .didProof:
        return "인증 완료"
      case let .didNotProof(time):
        return "\(time)까지"
    }
  }
}

enum FeedsType {
  case initialPage([FeedPresentationModel])
  case `default`([FeedPresentationModel])
}
