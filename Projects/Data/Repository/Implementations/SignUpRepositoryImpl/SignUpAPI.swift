//
//  SignUpAPI.swift
//  DTO
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum SignUpAPI {
  case requestVerificationCode(dto: RequestVerificationCodeReqeustDTO)
  case verifyCode(dto: VerifyCodeRequestDTO)
  case verifyUserName(String)
}

extension SignUpAPI: TargetType {
  public var baseURL: URL {
    return URL(string: "http://localhost:8080")!
//    return URL(string: ServiceConfiguration.baseUrl)!
  }
  
  public var path: String {
    switch self {
      case .requestVerificationCode:
        return "api/contacts"
      case .verifyCode:
        return "api/contacts/verify"
      case .verifyUserName:
        return "api/users/username"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .requestVerificationCode:
        return .post
      case .verifyCode:
        return .patch
      case .verifyUserName:
        return .get
    }
  }
  
  public var task: TaskType {
    switch self {
      case let .requestVerificationCode(dto):
        return .requestJSONEncodable(dto)
      case let .verifyCode(dto):
        return .requestJSONEncodable(dto)
      case let .verifyUserName(userName):
        let parameters = ["username": userName]
        return .requestParameters(
          parameters: parameters,
          encoding: URLEncoding.init(destination: .queryString)
        )
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .requestVerificationCode:
        let responseData = RequestVerificationCodeReqeustDTO.stubData
        let jsonData = responseData.data(using: .utf8)
        
        return .networkResponse(409, jsonData ?? Data(), "", "")
        
      case .verifyCode:
        let responseData = VerifyCodeRequestDTO.stubData
        let jsonData = responseData.data(using: .utf8)
        
        return .networkResponse(400, jsonData ?? Data(), "", "")
    }
  }
}
