//
//  ChangePasswordRequestDTO.swift
//  Data
//
//  Created by wooseob on 12/5/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct ChangePasswordRequestDTO: Encodable {
  public let password: String
  public let newPassword: String
  public let newPasswordReEnter: String
  
  public init(
    password: String,
    newPassword: String,
    newPasswordReEnter: String
  ) {
    self.password = password
    self.newPassword = newPassword
    self.newPasswordReEnter = newPasswordReEnter
  }
}
