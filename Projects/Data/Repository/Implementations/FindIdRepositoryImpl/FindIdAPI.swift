//
//  FindIdAPI.swift
//  Data
//
//  Created by 임우섭 on 12/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum FindIdAPI {
  case findId(dto: FindIdRequestDTO)
}

extension FindIdAPI: TargetType {
  public var baseURL: URL {
    //    return ServiceConfiguration.baseUrl
    return URL(string: "http://localhost:8080")!
  }
  
  public var path: String {
    switch self {
      case .findId:
        return "api/users/find-username"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .findId: return .post
    }
  }
  
  public var task: TaskType {
    switch self {
      case let .findId(dto):
        return .requestJSONEncodable(dto)
    }
  }
}
