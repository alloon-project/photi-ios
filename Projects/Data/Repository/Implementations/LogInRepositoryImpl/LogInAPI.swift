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
  case findId(email: String)
  case findPassword(dto: FindPasswordRequestDTO)
}

extension LogInAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
      case .login: return "api/users/login"
      case .findId: return "api/users/find-username"
      case .findPassword: return "api/users/find-password"
    }
  }
  
  public var method: HTTPMethod {
    return .post
  }
  
  public var task: TaskType {
    switch self {
      case let .login(dto):
        return .requestJSONEncodable(dto)
        
      case let .findPassword(dto):
        return .requestJSONEncodable(dto)
        
      case let .findId(email):
        let parameter = ["email": email]
        return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .login:
        let responseData = LogInRequestDTO.stubData
        let jsonData = responseData.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "", "")
        
      case .findPassword, .findId:
        let data = """
          {
            "code": "200 OK",
            "message": "성공",
            "data": {
              successMessage: "string"
            }         
          }
        """
        let jsonData = data.data(using: .utf8)
        return .networkResponse(200, jsonData ?? Data(), "", "")
    }
  }
}
