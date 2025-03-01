//
//  CommentPresentationModel.swift
//  Presentation
//
//  Created by jung on 12/17/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

struct FeedCommentPresentationModel: Hashable {
  let id: String
  var commentId: Int
  let author: String
  let content: String
  let isOwner: Bool
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

enum FeedCommentType {
  case initialPage([FeedCommentPresentationModel])
  case `default`([FeedCommentPresentationModel])
}
