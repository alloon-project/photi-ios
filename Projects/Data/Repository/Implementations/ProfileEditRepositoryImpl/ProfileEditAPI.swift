//
//  ProfileEditAPI.swift
//  DTO
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum ProfileEditAPI {
  case userInfo
}

extension ProfileEditAPI: TargetType {
  public var baseURL: URL {
    return URL(string: "http://localhost:8080")!
    //    return URL(string: ServiceConfiguration.baseUrl)!
  }
  
  public var path: String {
    switch self {
    case .userInfo:
      return "api/users"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .userInfo:
      return .get
    }
  }
  
  public var task: TaskType {
    switch self {
      case .userInfo:
      return .requestPlain
    }
  }
}
