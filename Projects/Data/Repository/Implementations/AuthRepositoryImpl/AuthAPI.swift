//
//  AuthAPI.swift
//  DTO
//
//  Created by jung on 2/12/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum AuthAPI {
  case isLogIn
}

extension AuthAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
      case .isLogIn: return "api/auth/validate/access-token"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .isLogIn: return .get
    }
  }
  
  public var task: TaskType {
    switch self {
      case .isLogIn:  return .requestPlain
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .isLogIn:
        let data = AuthAPI.sampleData.data(using: .utf8) ?? Data()
        
        return .networkResponse(200, data, "", "")
    }
  }
}

fileprivate extension AuthAPI {
  static let sampleData = """
    {
    "code": "200 OK",
    "message": "성공",
    "data": {
      "successMessage": "string"
      }
    }
  """
}
