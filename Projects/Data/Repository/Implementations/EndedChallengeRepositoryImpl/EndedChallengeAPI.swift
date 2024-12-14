//
//  EndedChallengeAPI.swift
//  Data
//
//  Created by 임우섭 on 11/3/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum EndedChallengeAPI {
  case endedChallenges(dto: EndedChallengeRequestDTO)
}

extension EndedChallengeAPI: TargetType {
  public var baseURL: URL {
    return URL(string: "http://localhost:8080")!
    //    return URL(string: ServiceConfiguration.baseUrl)!
  }
  
  public var path: String {
    switch self {
    case .endedChallenges:
      return "api/users/ended-challenges"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
    case .endedChallenges:
      return .get
    }
  }
  
  public var task: TaskType {
    switch self {
    case let .endedChallenges(dto):
      return .requestJSONEncodable(dto)
    }
  }
}
