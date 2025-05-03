//
//  FeedPresentatoinModelMapper.swift
//  ChallengeImpl
//
//  Created by jung on 2/26/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core
import Entity

struct FeedPresentatoinModelMapper {
  private let dummyCommentId = -1
  
  func mapToFeedPresentationModels(_ feeds: [Feed]) -> [FeedPresentationModel] {
    return feeds.map { feed in
      return .init(
        id: feed.id,
        imageURL: feed.imageURL,
        userName: feed.author,
        updateTime: mapToUpdateTimeString(feed.updateTime),
        updateGroup: mapToUpdateGroup(feed.updateTime),
        isLike: feed.isLike
      )
    }
  }
  
  func mapToAuthorPresentaionModel(author: String, url: URL?) -> AuthorPresentationModel {
    return .init(name: author, imageURL: url)
  }
  
  func mapToFeedCommentPresentationModels(_ comments: [FeedComment]) -> [FeedCommentPresentationModel] {
    return comments.map {
      .init(
        id: UUID().uuidString,
        commentId: $0.id,
        author: $0.author,
        content: $0.comment,
        isOwner: isOwner($0.author)
      )
    }
  }
  
  func feedCommentPresentationModel(_ comment: String) -> FeedCommentPresentationModel {
    return .init(
      id: UUID().uuidString,
      commentId: dummyCommentId,
      author: ServiceConfiguration.shared.userName,
      content: comment,
      isOwner: true
    )
  }
}

extension FeedPresentatoinModelMapper {
  func mapToUpdateTimeString(_ date: Date) -> String {
    let date = date.convertTimezone(from: .kst)
    let current = Date()
    let interval = current.timeIntervalSince(date)
    let days = Int(interval / 86400) // 24 * 60 * 60
    
    guard days < 365 else { return "\(days / 365)년 전" }
    guard days < 30 else { return "\(days / 30)달 전" }
    guard days < 1 else { return "\(days)일 전"}
    
    let hours = Int(interval / 3600)
    let minutes = Int(interval / 60)
  
    guard hours < 1 else { return "\(hours)시간 전" }
    
    if minutes <= 0 {
      return "방금"
    } else if minutes <= 10 {
      return "\(minutes)분 전"
    } else {
      return "\(minutes / 10 * 10)분 전"
    }
  }
  
  func mapToUpdateGroup(_ date: Date) -> String {
    let date = date.convertTimezone(from: .kst)
    let current = Date()
    let interval = current.timeIntervalSince(date)
    let days = Int(interval / 86400)

    if days >= 365 {
      return "\(days / 365)년 전"
    } else if days >= 30 {
      return "\(days / 30)달 전"
    } else {
      return days == 0 ? "오늘" : "\(days)일 전"
    }
  }
}

// MARK: - Private Methods
private extension FeedPresentatoinModelMapper {
  func isOwner(_ name: String) -> Bool {
    return name == ServiceConfiguration.shared.userName
  }
}
