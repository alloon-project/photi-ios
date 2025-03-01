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
  
    guard current.year == date.year else {
      return "\(abs(current.year - date.year))년 전"
    }
  
    guard current.month == date.month else {
      return "\(abs(current.month - date.month))년 전"
    }
  
    guard current.day == date.day else {
      return "\(abs(current.day - date.day))일 전"
    }
  
    guard current.hour == date.hour else {
      return "\(abs(current.hour - date.hour))시간 전"
    }
  
    guard current.minute != date.minute else {
      return "방금"
    }
  
    let temp = abs(current.minute - date.minute)
    switch temp {
      case 0...10: return "\(temp)분 전"
      default: return "\(temp / 10)분 전"
    }
  }
  
  func mapToUpdateGroup(_ date: Date) -> String {
    let date = date.convertTimezone(from: .kst)
    let current = Date()
  
    guard current.year == date.year else {
      return "\(abs(current.year - date.year))년 전"
    }
  
    guard current.month == date.month else {
      return "\(abs(current.month - date.month))년 전"
    }
  
    let temp = abs(current.day - date.day)
    return temp == 0 ? "오늘" : "\(temp)일 전"
  }
}

// MARK: - Private Methods
private extension FeedPresentatoinModelMapper {
  func isOwner(_ name: String) -> Bool {
    return name == ServiceConfiguration.shared.userName
  }
}
