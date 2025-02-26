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
  case joinChallenge(id: Int)
  case joinPrivateChallenge(id: Int, code: String)
  case feeds(id: Int, page: Int, size: Int, sortOrder: String)
  case uploadChallengeProof(id: Int, image: Data, imageType: String)
  case updateLikeState(challengeId: Int, feedId: Int, isLike: Bool)
  case isProve(challengeId: Int)
  case feedDetail(challengeId: Int, feedId: Int)
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
      case let .joinChallenge(id): return "challenges/\(id)/join/public"
      case let .joinPrivateChallenge(id, _): return "challenges/\(id)/join/private"
      case let .feeds(id, _, _, _): return "challenges/\(id)/feeds"
      case let .uploadChallengeProof(id, _, _): return "challenges/\(id)/feeds"
      case let .updateLikeState(challengeId, feedId, _): return "challenges/\(challengeId)/feeds/\(feedId)/like"
      case let .isProve(challengeId): return "/users/challenges/\(challengeId)/prove"
      case let .feedDetail(challengeId, feedId): return "/challenges/\(challengeId)/feeds/\(feedId)"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .popularChallenges: return .get
      case .challengeDetail: return .get
      case .endedChallenges: return .get
      case .joinChallenge: return .post
      case .joinPrivateChallenge: return .post
      case .feeds: return .get
      case .uploadChallengeProof: return .post
      case let .updateLikeState(_, _, isLike): return isLike ? .post : .delete
      case .isProve: return .get
      case .feedDetail: return .get
    }
  }
  
  public var task: TaskType {
    switch self {
      case .popularChallenges:
        return .requestPlain
        
      case let .challengeDetail(challengeId):
        let parameters = ["challengeId": challengeId]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .endedChallenges(page, size):
        let parameters = ["page": page, "size": size]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case .joinChallenge:
        return .requestPlain
        
      case let .joinPrivateChallenge(_, code):
        let parameters = ["invitationCode": code]
        return .requestParameters(
          parameters: parameters,
          encoding: JSONEncoding.default
        )
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
        
      case .joinChallenge, .joinPrivateChallenge, .uploadChallengeProof, .updateLikeState:
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
    }
  }
}
