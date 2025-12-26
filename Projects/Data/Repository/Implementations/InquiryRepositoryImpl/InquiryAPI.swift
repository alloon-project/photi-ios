//
//  InquiryAPI.swift
//  Data
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum InquiryAPI {
  case inquiry(dto: InquiryRequestDTO)
}

extension InquiryAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
      case .inquiry:
        return "inquiries"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .inquiry: return .post
    }
  }
  
  public var task: TaskType {
    switch self {
      case let .inquiry(dto):
        return .requestJSONEncodable(dto)
    }
  }
}
