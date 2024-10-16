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
}

extension ChallengeAPI: TargetType {
  public var baseURL: URL {
    //    return ServiceConfiguration.baseUrl
    return URL(string: "http://localhost:8080/challenges")!
  }
  
  public var path: String {
    switch self {
      case .popularChallenges: return "popular"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .popularChallenges: return .get
    }
  }
  
  public var task: TaskType {
    switch self {
      case .popularChallenges:
        return .requestPlain
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .popularChallenges:
        let data = ChallengeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
    }
  }
}
