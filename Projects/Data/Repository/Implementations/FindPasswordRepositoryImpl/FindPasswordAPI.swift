//
//  FindPasswordAPI.swift
//  Data
//
//  Created by wooseob on 11/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum FindPasswordAPI {
  case findPassword(dto: FindPasswordRequestDTO)
}

extension FindPasswordAPI: TargetType {
  public var baseURL: URL {
    //    return ServiceConfiguration.baseUrl
    return URL(string: "http://localhost:8080")!
  }
  
  public var path: String {
    switch self {
      case .findPassword:
        return "api/users/find-userword"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .findPassword: return .post
    }
  }
  
  public var task: TaskType {
    switch self {
      case let .findPassword(dto):
        return .requestJSONEncodable(dto)
    }
  }
}
