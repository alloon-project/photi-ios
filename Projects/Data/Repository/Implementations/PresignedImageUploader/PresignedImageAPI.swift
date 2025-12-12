//
//  PresignedImageAPI.swift
//  DTO
//
//  Created by jung on 12/10/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core
import PhotiNetwork

enum PresignedImageAPI {
  case getPresignedURL(filename: String)
  // URL로 전달해줄지 이걸 고민해야해.
  case postImage(path: URL, data: Data)
}

extension PresignedImageAPI: TargetType {
  var baseURL: URL {
    switch self {
      case let .postImage(path, _): return path
      default: return ServiceConfiguration.shared.baseUrl
    }
  }
  
  var path: String {
    switch self {
      case .getPresignedURL: return "user/image/pre-signed-url"
      case .postImage: return ""
    }
  }
  
  var method: HTTPMethod {
    switch self {
      case .getPresignedURL, .postImage: return .post
    }
  }
  
  var task: TaskType {
    switch self {
      case let .getPresignedURL(fileName):
        let parameters = ["imageName": fileName]
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
      case let .postImage(_, data):
        return .requestData(data)
    }
  }
}
