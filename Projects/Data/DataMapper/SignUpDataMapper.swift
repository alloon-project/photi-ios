//
//  SignUpDataMapper.swift
//  DTO
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DTO

public protocol SignUpDataMapper {
  func mapToRequestVerificationRequestDTO(email: String) -> RequestVerificationCodeReqeustDTO
  
  func mapToVerifyCodeRequestDTO(email: String, code: String) -> VerifyCodeRequestDTO
  
  func mapToRegisterRequestDTO(
    email: String,
    username: String,
    password: String
  ) -> RegisterRequestDTO
}

public struct SignUpDataMapperImpl: SignUpDataMapper {
  public init() {}
  
  public func mapToRequestVerificationRequestDTO(email: String) -> RequestVerificationCodeReqeustDTO {
    return .init(email: email)
  }
  
  public func mapToVerifyCodeRequestDTO(email: String, code: String) -> VerifyCodeRequestDTO {
    return .init(email: email, code: code)
  }
  
  public func mapToRegisterRequestDTO(
    email: String,
    username: String,
    password: String
  ) -> RegisterRequestDTO {
    return .init(
      email: email,
      username: username,
      password: password
      )
  }
}
