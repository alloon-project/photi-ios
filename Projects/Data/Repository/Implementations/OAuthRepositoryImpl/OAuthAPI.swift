//
//  OAuthAPI.swift
//  Data
//
//  Created by Claude on 3/15/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum OAuthAPI {
  case login(provider: String, idToken: String)
  case setUsername(dto: OAuthUsernameRequestDTO)
  /// 카카오/구글 탈퇴 - 클라이언트에서 unlink 후 호출
  case withdrawKakaoGoogle(dto: OAuthWithdrawRequestDTO)
  /// 애플 탈퇴 - 서버에서 revoke 처리
  case withdrawApple(accessToken: String)
}

extension OAuthAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }

  public var path: String {
    switch self {
    case let .login(provider, _):
      return "oauth/\(provider)/login"
    case .setUsername:
      return "oauth/username"
    case .withdrawKakaoGoogle:
      return "oauth/withdraw"
    case .withdrawApple:
      return "oauth/apple/withdraw"
    }
  }

  public var method: HTTPMethod {
    switch self {
    case .login:
      return .get
    case .setUsername:
      return .post
    case .withdrawKakaoGoogle, .withdrawApple:
      return .patch
    }
  }

  public var task: TaskType {
    switch self {
    case let .login(_, idToken):
      let parameters = ["id_token": idToken]
      return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

    case let .setUsername(dto):
      return .requestJSONEncodable(dto)

    case let .withdrawKakaoGoogle(dto):
      return .requestJSONEncodable(dto)

    case let .withdrawApple(accessToken):
      let parameters = ["access_token": accessToken]
      return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }
  }

  public var sampleResponse: EndpointSampleResponse {
    switch self {
    case .login:
      let data = """
          {
            "code": "200 OK",
            "message": "성공",
            "data": {
              "username": null
            }
          }
        """
      let jsonData = data.data(using: .utf8)
      return .networkResponse(200, jsonData ?? Data(), "", "")

    case .setUsername:
      let data = """
          {
            "code": "200 OK",
            "message": "성공",
            "data": null
          }
        """
      let jsonData = data.data(using: .utf8)
      return .networkResponse(200, jsonData ?? Data(), "", "")

    case .withdrawKakaoGoogle, .withdrawApple:
      let data = """
          {
            "code": "200 OK",
            "message": "성공",
            "data": {
              "successMessage": "string"
            }
          }
        """
      let jsonData = data.data(using: .utf8)
      return .networkResponse(200, jsonData ?? Data(), "", "")
    }
  }
}
