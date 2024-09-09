//
//  RegisterRequestDTO.swift
//  DTO
//
//  Created by jung on 8/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct RegisterRequestDTO: Encodable {
  public let email: String
  public let verificationCode: String
  public let username: String
  public let password: String
  public let passwordReEnter: String
  
  public init(
    email: String,
    verificationCode: String,
    username: String,
    password: String,
    passwordReEnter: String
  ) {
    self.email = email
    self.verificationCode = verificationCode
    self.username = username
    self.password = password
    self.passwordReEnter = passwordReEnter
  }
}

#if DEBUG
extension RegisterRequestDTO {
  public static let stubData =
 """
 {
   "code": "FAIL",
   "message": "FAIL",
   "data": {
      "successMessage": "성공"
   },
 }
 """
}
#endif
