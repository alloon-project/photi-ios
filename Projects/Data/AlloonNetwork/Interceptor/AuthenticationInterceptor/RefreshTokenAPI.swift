//
//  RefreshTokenAPI.swift
//  AlloonNetwork
//
//  Created by jung on 5/22/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

enum RefreshTokenAPI {
  case refresh(_ token: String)
}

extension RefreshTokenAPI: TargetType {
  var baseURL: URL {
    return URL(string: URLString.base.url)!
  }
  
  var path: String {
    "api/users/token"
  }
  
  var method: HTTPMethod {
    .post
  }
  
  var headers: HTTPHeaders {
    switch self {
      case let .refresh(token):
        return HTTPHeaders([.refreshToken(token)])
    }
  }
  
  var task: TaskType {
    return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
  }
}
