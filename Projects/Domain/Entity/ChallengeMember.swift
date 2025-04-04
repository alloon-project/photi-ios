//
//  ChallengeMember.swift
//  Entity
//
//  Created by jung on 3/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeMember {
  public let id: Int
  public let name: String
  public let imageUrl: URL?
  public let isCreator: Bool
  public let duration: Int
  public let goal: String
  
  public init(
    id: Int,
    name: String,
    imageUrl: URL?,
    isOwner: Bool,
    duration: Int,
    goal: String
  ) {
    self.id = id
    self.name = name
    self.imageUrl = imageUrl
    self.isCreator = isOwner
    self.duration = duration
    self.goal = goal
  }
}
