//
//  Feed.swift
//  Entity
//
//  Created by jung on 2/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct Feed {
  public let id: Int
  public let author: String
  public let imageURL: URL
  public let isLike: Bool
  public let updateTime: Date
  
  public init(
    id: Int,
    author: String,
    imageURL: URL,
    isLike: Bool,
    updateTime: Date
  ) {
    self.id = id
    self.author = author
    self.imageURL = imageURL
    self.isLike = isLike
    self.updateTime = updateTime
  }
}
