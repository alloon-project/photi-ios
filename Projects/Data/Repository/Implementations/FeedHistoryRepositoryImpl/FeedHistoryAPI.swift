//
//  FeedHistoryAPI.swift
//  Data
//
//  Created by 임우섭 on 2/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum FeedHistoryAPI {
  case feedHistory(page: Int, size: Int)
}

extension FeedHistoryAPI: TargetType {
  public var baseURL: URL {
    //    return ServiceConfiguration.baseUrl
    return URL(string: "http://localhost:8080/api")!
  }
  
  public var path: String {
    switch self {
    case .feedHistory: return "users/feed-history"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
    case .feedHistory: return .get
    }
  }
  
  public var task: TaskType {
    switch self {
    case let .feedHistory(page, size):
      let parameters = ["page": page, "size": size]
      return .requestParameters(parameters: parameters, encoding: URLEncoding(destination: .queryString))
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
    case .feedHistory:
      let data = FeedHistoryResponseDTO.stubData
      let jsonData = data.data(using: .utf8)
      
      return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
    }
  }
}
