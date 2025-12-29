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
  case register(dto: RegisterRequestDTO)
  case deletedDate(email: String)
}

extension SignUpAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
      case .requestVerificationCode, .verifyCode: return "auth/code"
      case .verifyUserName: return "auth/validate/name"
      case .register: return "auth"
      case .deletedDate: return "auth/deleted-date"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .requestVerificationCode, .deletedDate, .register: return .post
      case .verifyCode: return .patch
      case .verifyUserName: return .get
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
          encoding: URLEncoding(destination: .queryString)
        )
      case let .register(dto):
        return .requestParameters(
          parameters: dto.toDictionary,
          encoding: JSONEncoding.default
        )
      case let .deletedDate(email):
        let parameters = ["email": email]
        return .requestParameters(
          parameters: parameters,
          encoding: JSONEncoding.default
        )
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .requestVerificationCode:
        let responseData = RequestVerificationCodeReqeustDTO.stubData
        let jsonData = responseData.data(using: .utf8)
        
        return .networkResponse(201, jsonData ?? Data(), "", "")
        
      case .verifyCode:
        let responseData = VerifyCodeRequestDTO.stubData
        let jsonData = responseData.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "", "")
        
      case .verifyUserName:
        let responseData = VerifyCodeRequestDTO.stubData
        let jsonData = responseData.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "", "")
        
      case .register:
        let responseData = RegisterRequestDTO.stubData
        let jsonData = responseData.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "", "")
        
      case .deletedDate:
        let responseData = DeletedDateResponseDTO.stubData
        let jsonData = responseData.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "", "")
    }
  }
}
