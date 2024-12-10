//
//  ChangePasswordAPI.swift
//  Data
//
//  Created by wooseob on 12/5/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum ChangePasswordAPI {
  case changePassword(dto: ChangePasswordRequestDTO)
}

extension ChangePasswordAPI: TargetType {
  public var baseURL: URL {
    //    return ServiceConfiguration.baseUrl
    return URL(string: "http://localhost:8080")!
  }
  
  public var path: String {
    switch self {
    case .changePassword:
        return "api/users/password"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
    case .changePassword: return .patch
    }
  }
  
  public var task: TaskType {
    switch self {
    case let .changePassword(dto):
        return .requestJSONEncodable(dto)
    }
  }
}
