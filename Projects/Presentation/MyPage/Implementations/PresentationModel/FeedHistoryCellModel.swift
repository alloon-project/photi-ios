//
//  FeedHistoryCellModel.swift
//  Presentaion
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

struct FeedHistoryCellPresentationModel: Hashable {
  let challengeId: Int
  let feedId: Int
  let feedImageUrl: URL?
  let challengeTitle: String
  let provedDate: String
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(challengeId)
    hasher.combine(feedId)
  }
}
