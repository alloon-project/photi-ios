//
//  SignUpAPI.swift
//  DTO
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum SignUpAPI {
  case requestVerificationCode(dto: RequestVerificationCodeReqeustDTO)
}

extension SignUpAPI: TargetType {
  public var baseURL: URL {
    return URL(string: "http://localhost:8080")!
//    return URL(string: ServiceConfiguration.baseUrl)!
  }
  
  public var path: String {
    switch self {
      case .requestVerificationCode:
        return "api/contacts"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .requestVerificationCode:
        return .post
    }
  }
  
  public var task: TaskType {
    switch self {
      case let .requestVerificationCode(dto):
        return .requestJSONEncodable(dto)
    }
  }
}
