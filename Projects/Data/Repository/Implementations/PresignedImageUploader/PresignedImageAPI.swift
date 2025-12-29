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
  case getPresignedURL(filename: String, uploadType: String)
  case postImage(path: URL, data: Data, imgType: String)
}

extension PresignedImageAPI: TargetType {
  var baseURL: URL {
    switch self {
      case let .postImage(path, _, _): return path
      default: return ServiceConfiguration.shared.baseUrl
    }
  }
  
  var headers: HTTPHeaders {
    switch self {
      case let .postImage(_, _, imgType): return .init(["Content-Type": "image/\(imgType)"])
      default: return HTTPHeaders()
    }
  }
  
  var path: String {
    switch self {
      case let .getPresignedURL(_, type): return "\(type)/image/pre-signed-url"
      case .postImage: return ""
    }
  }
  
  var method: HTTPMethod {
    switch self {
      case .getPresignedURL: return .post
      case .postImage: return .put
    }
  }
  
  var task: TaskType {
    switch self {
      case let .getPresignedURL(fileName, _):
        let parameters = ["imageName": fileName]
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
      case let .postImage(_, data, _):
        return .requestData(data)
    }
  }
}
