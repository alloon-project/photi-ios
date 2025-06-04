//
//  UpdatePasswordRequstDTO.swift
//  DTO
//
//  Created by jung on 6/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct UpdatePasswordRequstDTO: Encodable {
  public let password: String
  public let newPassword: String
  public let newPasswordReEnter: String
  
  public init(password: String, newPassword: String) {
    self.password = password
    self.newPassword = newPassword
    self.newPasswordReEnter = newPassword
  }
}
