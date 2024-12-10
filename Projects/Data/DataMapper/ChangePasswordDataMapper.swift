//
//  ChangePasswordDataMapper.swift
//  Data
//
//  Created by wooseob on 12/5/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DTO

public protocol ChangePasswordDataMapper {
  func mapToChangePasswordRequestDTO(
    password: String,
    newPassword: String,
    newPasswordReEnter: String
  ) -> ChangePasswordRequestDTO
}

public struct ChangePasswordDataMapperImpl: ChangePasswordDataMapper {
  public init() {}
  
  public func mapToChangePasswordRequestDTO(
    password: String,
    newPassword: String,
    newPasswordReEnter: String
  ) -> ChangePasswordRequestDTO {
    return ChangePasswordRequestDTO(
      password: password,
      newPassword: newPassword,
      newPasswordReEnter: newPasswordReEnter
    )
  }
}
