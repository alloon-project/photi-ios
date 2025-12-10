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
  case updatePassword(dto: UpdatePasswordRequstDTO)
}

extension LogInAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
      case .login: return "users/login"
      case .findId: return "users/find-username"
      case .findPassword: return "users/find-password"
      case .updatePassword: return "users/password"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .updatePassword: return .patch
      default: return .post
    }
  }
  
  public var task: TaskType {
    switch self {
      case let .login(dto):
        return .requestJSONEncodable(dto)
        
      case let .findPassword(dto):
        return .requestJSONEncodable(dto)
        
      case let .updatePassword(dto):
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
        
      case .findPassword, .findId, .updatePassword:
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
