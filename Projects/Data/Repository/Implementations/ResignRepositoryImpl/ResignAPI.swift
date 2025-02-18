//
//  ResignAPI.swift
//  Data
//
//  Created by 임우섭 on 2/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum ResignAPI {
  case resign(dto: ResignRequestDTO)
}

extension ResignAPI: TargetType {
  public var baseURL: URL {
    //    return ServiceConfiguration.baseUrl
    return URL(string: "http://localhost:8080")!
  }
  
  public var path: String {
    switch self {
    case .resign: return "api/users"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
    case .resign: return .patch
    }
  }
  
  public var task: TaskType {
    switch self {
    case let .resign(dto):
        return .requestJSONEncodable(dto)
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
    case .resign:
      let data = ResignRequestDTO.stubData
      let jsonData = data.data(using: .utf8)
      
      return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
    }
  }
}
