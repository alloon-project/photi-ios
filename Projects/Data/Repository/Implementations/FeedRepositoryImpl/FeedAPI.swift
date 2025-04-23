//
//  FeedAPI.swift
//  DTO
//
//  Created by jung on 3/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum FeedAPI {
  case feeds(id: Int, page: Int, size: Int, sortOrder: String)
  case updateLikeState(challengeId: Int, feedId: Int, isLike: Bool)
  case feedDetail(challengeId: Int, feedId: Int)
  case deleteFeed(challengeId: Int, feedId: Int)
  case feedComments(feedId: Int, page: Int, size: Int)
  case uploadFeedComment(challengeId: Int, feedId: Int, comment: String)
  case deleteFeedComment(challengeId: Int, feedId: Int, commentId: Int)
  case feedHistory(page: Int, size: Int)
}

extension FeedAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
      case let .feeds(id, _, _, _): return "api/challenges/\(id)/feeds"
      case let .updateLikeState(challengeId, feedId, _): return "api/challenges/\(challengeId)/feeds/\(feedId)/like"
      case let .feedDetail(challengeId, feedId): return "api/challenges/\(challengeId)/feeds/\(feedId)"
      case let .deleteFeed(challengeId, feedId): return "api/challenges/\(challengeId)/feeds/\(feedId)"
      case let .feedComments(feedId, _, _): return "api/challenges/feeds/\(feedId)/comments"
      case let .uploadFeedComment(challengeId, feedId, _):
        return "api/challenges/\(challengeId)/feeds/\(feedId)/comments"
      case let .deleteFeedComment(challengeId, feedId, commentId):
        return "api/challenges/\(challengeId)/feeds/\(feedId)/comments/\(commentId)"
     case .feedHistory: return "api/users/feed-history"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .feeds: return .get
      case let .updateLikeState(_, _, isLike): return isLike ? .post : .delete
      case .feedDetail: return .get
      case .feedComments: return .get
      case .uploadFeedComment: return .post
      case .deleteFeedComment, .deleteFeed: return .delete
      case .feedHistory: return .get
    }
  }
  
  public var task: TaskType {
    switch self {
      case let .feeds(_, page, size, ordered):
        let parameters = ["page": "\(page)", "size": "\(size)", "sorted": ordered]
        return .requestParameters(
          parameters: parameters,
          encoding: URLEncoding.queryString
        )
        
      case .updateLikeState, .feedDetail, .deleteFeedComment, .deleteFeed:
        return .requestPlain
        
      case let .feedComments(_, page, size):
        let parameters = ["page": "\(page)", "size": "\(size)"]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .uploadFeedComment(_, _, comment):
        let parameters = ["comment": comment]
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        
      case let .feedHistory(page, size):
        let parameters = ["page": page, "size": size]
        return .requestParameters(parameters: parameters, encoding: URLEncoding(destination: .queryString))
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .updateLikeState, .deleteFeedComment, .deleteFeed:
        let data = """
          {
            "code": "200 OK",
            "message": "성공",
            "data": {
              "successMessage": "string"
            }
          }
        """
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .uploadFeedComment:
        let data = IDResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case let .feeds(_, page, _, _):
        let feedsData = [FeedsResponseDTO.stubData, FeedsResponseDTO.stubData2, FeedsResponseDTO.stubData3]
        let data = feedsData[page]
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .feedDetail:
        let data = FeedDetailResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case let .feedComments(_, page, _):
        let page = min(page, 1)
        let commentsData = [FeedCommentsResponseDTO.stubData1, FeedCommentsResponseDTO.stubData2]
        let jsonData = commentsData[page].data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
      case .feedHistory:
        let data = FeedHistoryResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
    }
  }
}
