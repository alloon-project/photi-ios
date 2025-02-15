//
//  ReportAPI.swift
//  Data
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum ReportAPI {
  case report(dto: ReportRequestDTO, targetId: Int)
}

extension ReportAPI: TargetType {
  public var baseURL: URL {
    //    return ServiceConfiguration.baseUrl
    return URL(string: "http://localhost:8080")!
  }
  
  public var path: String {
    switch self {
      case .report:
        return "api/reports"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .report: return .post
    }
  }
  
  public var task: TaskType {
    switch self {
      case let .report(dto, targetId):
      return .requestCompositeParameters(
        bodyParameters: dto.toDictionary,
        urlParameters: ["targetId": targetId])
    }
  }
}
