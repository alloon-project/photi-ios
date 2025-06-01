//
//  FeedHistoryCellModel.swift
//  Presentaion
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

struct FeedHistoryCellPresentationModel: Hashable {
  let feedId: Int
  let challengeImageUrl: URL?
  let challengeTitle: String
  let provedDate: String
  let challengeId: Int
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(feedId)
  }
}
