//
//  ChallengeAPI.swift
//  DTO
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum ChallengeAPI {
  case popularChallenges
  case challengeDetail(id: Int)
  case endedChallenges(page: Int, size: Int)
  case myChallenges(page: Int, size: Int)
  case joinChallenge(id: Int)
  case joinPrivateChallenge(id: Int, code: String)
  case feeds(id: Int, page: Int, size: Int, sortOrder: String)
  case uploadChallengeProof(id: Int, image: Data, imageType: String)
  case updateLikeState(challengeId: Int, feedId: Int, isLike: Bool)
  case isProve(challengeId: Int)
  case feedDetail(challengeId: Int, feedId: Int)
  case feedComments(feedId: Int, page: Int, size: Int)
  case uploadFeedComment(challengeId: Int, feedId: Int, comment: String)
  case deleteFeedComment(challengeId: Int, feedId: Int, commentId: Int)
  case updateChallengeGoal(_ goal: String, challengeId: Int)
  case challengeDescription(id: Int)
  case challengeMember(challengeId: Int)
}

extension ChallengeAPI: TargetType {
  public var baseURL: URL {
    //    return ServiceConfiguration.baseUrl
    return URL(string: "http://localhost:8080/api")!
  }
  
  public var path: String {
    switch self {
      case .popularChallenges: return "challenges/popular"
      case let .challengeDetail(id): return "challenges/\(id)"
      case .endedChallenges: return "users/ended-challenges"
      case .myChallenges: return "/users/my-challenges"
      case let .joinChallenge(id): return "challenges/\(id)/join/public"
      case let .joinPrivateChallenge(id, _): return "challenges/\(id)/join/private"
      case let .feeds(id, _, _, _): return "challenges/\(id)/feeds"
      case let .uploadChallengeProof(id, _, _): return "challenges/\(id)/feeds"
      case let .updateLikeState(challengeId, feedId, _): return "challenges/\(challengeId)/feeds/\(feedId)/like"
      case let .isProve(challengeId): return "/users/challenges/\(challengeId)/prove"
      case let .feedDetail(challengeId, feedId): return "/challenges/\(challengeId)/feeds/\(feedId)"
      case let .feedComments(feedId, _, _): return "/challenges/feeds/\(feedId)/comments"
      case let .uploadFeedComment(challengeId, feedId, _): 
        return "/challenges/\(challengeId)feeds/\(feedId)/comments"
      case let .deleteFeedComment(challengeId, feedId, commentId): 
        return "/challenges/\(challengeId)/feeds/\(feedId)/comments/\(commentId)"
      case let .updateChallengeGoal(_, challengeId): return "/challenges/\(challengeId)/challenge-members/goal"
      case let .challengeDescription(id): return "challenges/\(id)/info"
      case let .challengeMember(challengeId): return "/challenges/\(challengeId)/challenge-members"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .popularChallenges: return .get
      case .challengeDetail: return .get
      case .endedChallenges, .myChallenges: return .get
      case .joinChallenge, .joinPrivateChallenge: return .post
      case .feeds: return .get
      case .uploadChallengeProof: return .post
      case let .updateLikeState(_, _, isLike): return isLike ? .post : .delete
      case .isProve: return .get
      case .feedDetail: return .get
      case .feedComments: return .get
      case .uploadFeedComment: return .post
      case .deleteFeedComment: return .delete
      case .updateChallengeGoal: return .patch
      case .challengeDescription: return .get
      case .challengeMember: return .get
    }
  }
  
  public var task: TaskType {
    switch self {
      case .popularChallenges:
        return .requestPlain
        
      case let .challengeDetail(challengeId):
        let parameters = ["challengeId": challengeId]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .endedChallenges(page, size), let .myChallenges(page, size):
        let parameters = ["page": page, "size": size]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .joinChallenge(challengeId):
        let parameters = ["challengeId": "\(challengeId)"]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

      case let .joinPrivateChallenge(challengeId, code):
        let urlParameters = ["challengeId": challengeId]
        let bodyParameters = ["invitationCode": code]
        return .requestCompositeParameters(bodyParameters: bodyParameters, urlParameters: urlParameters)
        
      case let .feeds(challengeId, page, size, ordered):
        let parameters = ["challengeId": "\(challengeId)", "page": "\(page)", "size": "\(size)", "sort": ordered]
        return .requestParameters(
          parameters: parameters,
          encoding: URLEncoding.queryString
        )
        
      case let .uploadChallengeProof(challengeId, image, imageType):
        let parameters = ["challengeId": challengeId]

        let multiPartBody = MultipartFormDataBodyPart(
          .data(["imageFile": image]),
          fileExtension: imageType,
          mimeType: "image/\(imageType)"
        )
        
        return .uploadCompositeMultipart(
          multipart: .init(bodyParts: [multiPartBody]),
          urlParameters: parameters
        )
        
      case let .updateLikeState(challengeId, feedId, _), let .feedDetail(challengeId, feedId):
        let parameters = ["challengeId": challengeId, "feedId": feedId]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .isProve(challengeId):
        let parameters = ["challengeId": challengeId]
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
        
      case let .updateChallengeGoal(goal, challengeId):
        let urlParameters = ["challengeId": challengeId]
        let bodyParameters = ["goal": goal]
        return .requestCompositeParameters(bodyParameters: bodyParameters, urlParameters: urlParameters)
        
      case let .challengeDescription(challengeId):
        let parameters = ["challengeId": challengeId]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .challengeMember(challengeId):
        let parameters = ["challengeId": challengeId]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .popularChallenges:
        let data = PopularChallengeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .challengeDetail:
        let data = ChallengeDetailResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .endedChallenges:
        let data = EndedChallengeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .myChallenges:
        let data = MyChallengesResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")

      // swiftlint:disable line_length 
      case .joinChallenge, .joinPrivateChallenge, .uploadChallengeProof, .updateLikeState, .uploadFeedComment, .deleteFeedComment, .updateChallengeGoal:
      // swiftlint:enable line_length
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
        
      case let .feeds(_, page, _, _):
        let feedsData = [FeedsResponseDTO.stubData, FeedsResponseDTO.stubData2, FeedsResponseDTO.stubData3]
        let data = feedsData[page]
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .isProve:
        let data = ChallengeProveResponseDTO.stubData
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
        
      case .challengeDescription:
        let data = ChallengeDescriptionResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .challengeMember:
        let data = ChallengeMemberResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
    }
  }
}
