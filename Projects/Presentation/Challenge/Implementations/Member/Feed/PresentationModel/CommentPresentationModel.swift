//
//  CommentPresentationModel.swift
//  Presentation
//
//  Created by jung on 12/17/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

struct CommentPresentationModel: Hashable {
  let id: Int
  let author: String
  let content: String
  let isOwner: Bool
  let updatedAt: Date
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
