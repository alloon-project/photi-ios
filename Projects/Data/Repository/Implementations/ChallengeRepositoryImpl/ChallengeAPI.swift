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
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .popularChallenges: return .get
      case .challengeDetail: return .get
      case .endedChallenges: return .get
      case .joinChallenge: return .post
      case .joinPrivateChallenge: return .post
    }
  }
  
  public var task: TaskType {
    switch self {
      case .popularChallenges:
        return .requestPlain
      case .challengeDetail:
        return .requestPlain
      case let .endedChallenges(page, size):
        let parameters = ["page": page, "size": size]
        return .requestParameters(parameters: parameters, encoding: URLEncoding(destination: .queryString))
      case let .joinChallenge(id):
        return .requestPlain
      case let .joinPrivateChallenge(_, code):
        let parameters = ["invitationCode": code]
        return .requestParameters(
          parameters: parameters,
          encoding: JSONEncoding.default
        )
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
        
      case .joinChallenge, .joinPrivateChallenge:
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
    }
  }
}
