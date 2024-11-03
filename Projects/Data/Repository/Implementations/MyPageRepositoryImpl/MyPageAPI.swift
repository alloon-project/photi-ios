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
    return URL(string: "http://localhost:8080")!
    //    return URL(string: ServiceConfiguration.baseUrl)!
  }
  
  public var path: String {
    switch self {
    case .userChallegeHistory:
      return "api/users/challenge-history"
    }
  }
  
  public var method: PhotiNetwork.HTTPMethod {
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
}
