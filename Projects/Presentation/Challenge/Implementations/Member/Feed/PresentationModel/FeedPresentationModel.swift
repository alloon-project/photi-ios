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
  let updateGroup: String
  var isLike: Bool
}

enum FeedsAlignMode: String, CaseIterable {
  case recent = "최신순"
  case popular = "인기순"
  
  var toOrderType: ChallengeFeedsOrderType {
    switch self {
      case .recent: return .latest
      case .popular: return .popular
    }
  }
}

enum ProveType: Equatable {
  case didProve
  case didNotProve(String)
  
  var toString: String {
    switch self {
      case .didProve:
        return "인증 완료"
      case let .didNotProve(time):
        return "\(time)까지"
    }
  }
}

enum FeedsType: Equatable {
  case initialPage([FeedPresentationModel])
  case `default`([FeedPresentationModel])
  case empty
}
