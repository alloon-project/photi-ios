//
//  FeedHistoryCellModel.swift
//  Presentaion
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct FeedHistoryCellPresentationModel: Hashable {
  let feedId: Int
  let challengeImageUrl: URL?
  let challengeTitle: String
  let provedDate: String
  let challengeId: Int
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(feedId)
  }
}
