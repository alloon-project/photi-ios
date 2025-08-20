//
//  AppAPI.swift
//  DTO
//
//  Created by jung on 8/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum AppAPI {
  case appVersion(_ version: String)
}

extension AppAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
      case .appVersion: return "api/app-version"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .appVersion: return .post
    }
  }
  
  public var task: TaskType {
    switch self {
      case let .appVersion(version):
        let parameters = ["os": "iOS", "appVersion": "\(version)"]
        return .requestJSONEncodable(parameters)
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .appVersion:
        let data = AppVersionResponseDTO.stubData
        let jsonData = data.data(using: .utf8) ?? Data()
        
        return .networkResponse(200, jsonData, "", "")
    }
  }
}
