//
//  FeedComment.swift
//  Entity
//
//  Created by jung on 2/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct FeedComment {
  public let id: Int
  public let author: String
  public let comment: String
  
  public init(id: Int, author: String, comment: String) {
    self.id = id
    self.author = author
    self.comment = comment
  }
}
