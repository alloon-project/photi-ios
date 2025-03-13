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
  case feedComments(feedId: Int, page: Int, size: Int)
  case uploadFeedComment(challengeId: Int, feedId: Int, comment: String)
  case deleteFeedComment(challengeId: Int, feedId: Int, commentId: Int)
}

extension FeedAPI: TargetType {
  public var baseURL: URL {
    //    return ServiceConfiguration.baseUrl
    return URL(string: "http://localhost:8080/api")!
  }
  
  public var path: String {
    switch self {
      case let .feeds(id, _, _, _): return "challenges/\(id)/feeds"
      case let .updateLikeState(challengeId, feedId, _): return "challenges/\(challengeId)/feeds/\(feedId)/like"
      case let .feedDetail(challengeId, feedId): return "/challenges/\(challengeId)/feeds/\(feedId)"
      case let .feedComments(feedId, _, _): return "/challenges/feeds/\(feedId)/comments"
      case let .uploadFeedComment(challengeId, feedId, _):
        return "/challenges/\(challengeId)feeds/\(feedId)/comments"
      case let .deleteFeedComment(challengeId, feedId, commentId):
        return "/challenges/\(challengeId)/feeds/\(feedId)/comments/\(commentId)"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .feeds: return .get
      case let .updateLikeState(_, _, isLike): return isLike ? .post : .delete
      case .feedDetail: return .get
      case .feedComments: return .get
      case .uploadFeedComment: return .post
      case .deleteFeedComment: return .delete
    }
  }
  
  public var task: TaskType {
    switch self {
      case let .feeds(challengeId, page, size, ordered):
        let parameters = ["challengeId": "\(challengeId)", "page": "\(page)", "size": "\(size)", "sort": ordered]
        return .requestParameters(
          parameters: parameters,
          encoding: URLEncoding.queryString
        )
        
      case let .updateLikeState(challengeId, feedId, _), let .feedDetail(challengeId, feedId):
        let parameters = ["challengeId": challengeId, "feedId": feedId]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .feedComments(feedId, page, size):
        let parameters = ["feedId": "\(feedId)", "page": "\(page)", "size": "\(size)"]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .uploadFeedComment(challengeId, feedId, comment):
        let urlParameters = ["challengeId": challengeId, "feedId": feedId]
        let bodyParameters = ["comment": comment]
        return .requestCompositeParameters(bodyParameters: bodyParameters, urlParameters: urlParameters)
        
      case let .deleteFeedComment(challengeId, feedId, commentId):
        let parameters = ["challengeId": challengeId, "feedId": feedId, "commentId": commentId]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .updateLikeState, .deleteFeedComment:
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
        let data = FeedCommentResponseDTO.stubData
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
    }
  }
}
