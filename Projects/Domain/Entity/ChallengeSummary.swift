//
//  ChallengeSummary.swift
//  Entity
//
//  Created by jung on 1/29/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeSummary {
  public let id: Int
  public let name: String
  public let imageUrl: URL?
  public let endDate: Date
  public let hashTags: [String]
  
  // MARK: - Extra Properties
  public let proveTime: Date?
  public let feedImageURL: URL?
  public let memberCount: Int?
  public let memberImages: [URL]?
}

// MARK: - Initializers
public extension ChallengeSummary {
  init(
    id: Int,
    name: String,
    imageUrl: URL?,
    endDate: Date,
    hashTags: [String]
  ) {
    self.id = id
    self.name = name
    self.imageUrl = imageUrl
    self.endDate = endDate
    self.hashTags = hashTags
    self.proveTime = nil
    self.feedImageURL = nil
    self.memberCount = nil
    self.memberImages = nil
  }
  
  init(
    id: Int,
    name: String,
    imageUrl: URL?,
    endDate: Date,
    hashTags: [String],
    proveTime: Date,
    feedImageURL: URL?
  ) {
    self.id = id
    self.name = name
    self.imageUrl = imageUrl
    self.endDate = endDate
    self.hashTags = hashTags
    self.proveTime = proveTime
    self.feedImageURL = feedImageURL
    self.memberCount = nil
    self.memberImages = nil
  }
  
  init(
    id: Int,
    name: String,
    imageUrl: URL?,
    endDate: Date,
    hashTags: [String],
    memberCount: Int,
    memberImages: [URL]
  ) {
    self.id = id
    self.name = name
    self.imageUrl = imageUrl
    self.endDate = endDate
    self.hashTags = hashTags
    self.proveTime = nil
    self.feedImageURL = nil
    self.memberCount = memberCount
    self.memberImages = memberImages
  }
}
