//
//  MyPageAPI.swift
//  Data
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum MyPageAPI {
  case userChallegeHistory
}

extension MyPageAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
    case .userChallegeHistory:
      return "api/users/challenge-history"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
    case .userChallegeHistory:
      return .get
    }
  }
  
  public var task: PhotiNetwork.TaskType {
    switch self {
    case .userChallegeHistory:
      return .requestPlain
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
    case .userChallegeHistory:
      let data = UserChallengeHistoryResponseDTO.stubData
      let jsonData = data.data(using: .utf8)
      
      return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
    }
  }
}
