//
//  Challenge.swift
//  UseCase
//
//  Created by jung on 10/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct Challenge: Identifiable {
  public let id: Int
  public let name: String
  public let imageURL: URL?
  public let goal: String
  public let proveTime: Date
  public let endDate: Date
  public let hashTags: [String]
  
  public init(
    id: Int,
    name: String,
    imageURL: URL?,
    goal: String,
    proveTime: Date,
    endDate: Date,
    hashTags: [String]
  ) {
    self.id = id
    self.name = name
    self.imageURL = imageURL
    self.goal = goal
    self.proveTime = proveTime
    self.endDate = endDate
    self.hashTags = hashTags
  }
}
