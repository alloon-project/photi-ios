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
}

public struct SignUpDataMapperImpl: SignUpDataMapper {
  public init() {}
  
  public func mapToRequestVerificationRequestDTO(email: String) -> RequestVerificationCodeReqeustDTO {
    return .init(email: email)
  }
}
