//
//  LogInAPI.swift
//  DTO
//
//  Created by jung on 8/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum LogInAPI {
  case login(dto: LogInRequestDTO)
}

extension LogInAPI: TargetType {
  public var baseURL: URL {
    //    return ServiceConfiguration.baseUrl
    return URL(string: "http://localhost:8080")!
  }
  
  public var path: String {
    switch self {
      case .login:
        return "api/users/login"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .login: return .post
    }
  }
  
  public var task: TaskType {
    switch self {
      case let .login(dto):
        return .requestJSONEncodable(dto)
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .login:
        let responseData = LogInRequestDTO.stubData
        let jsonData = responseData.data(using: .utf8)
        
//        return .networkError(NSError())
        return .networkResponse(500, jsonData ?? Data(), "", "")
    }
  }
}
