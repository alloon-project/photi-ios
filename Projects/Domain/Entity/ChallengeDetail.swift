//
//  ChallengeDetail.swift
//  Entity
//
//  Created by jung on 1/29/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeDetail {
  public let id: Int
  public let name: String
  public let imageUrl: URL?
  public let endDate: Date
  public let hashTags: [String]
  
  public let proveTime: Date
  public let goal: String
  public let memberCount: Int
  public let memberImages: [URL]
  
  // MARK: - Extra Properties
  public let isPublic: Bool?
  public let rules: [String]?
  
  public init(
    id: Int,
    name: String,
    imageUrl: URL?,
    endDate: Date,
    hashTags: [String],
    proveTime: Date,
    goal: String,
    memberCount: Int,
    memberImages: [URL],
    isPublic: Bool?,
    rules: [String]
  ) {
    self.id = id
    self.name = name
    self.imageUrl = imageUrl
    self.endDate = endDate
    self.hashTags = hashTags
    self.proveTime = proveTime
    self.goal = goal
    self.memberCount = memberCount
    self.memberImages = memberImages
    self.isPublic = isPublic
    self.rules = rules
  }
}

// MARK: - Initializers
public extension ChallengeDetail {
  init(
    id: Int,
    name: String,
    imageUrl: URL?,
    endDate: Date,
    hashTags: [String],
    proveTime: Date,
    goal: String,
    memberCount: Int,
    memberImages: [URL]
  ) {
    self.id = id
    self.name = name
    self.imageUrl = imageUrl
    self.endDate = endDate
    self.hashTags = hashTags
    self.proveTime = proveTime
    self.goal = goal
    self.memberCount = memberCount
    self.memberImages = memberImages
    self.isPublic = nil
    self.rules = nil
  }
}
