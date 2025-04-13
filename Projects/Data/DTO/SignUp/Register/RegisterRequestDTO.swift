//
//  RegisterRequestDTO.swift
//  DTO
//
//  Created by jung on 8/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct RegisterRequestDTO: Encodable {
  public let email: String
  public let username: String
  public let password: String
  
  public init(
    email: String,
    username: String,
    password: String
  ) {
    self.email = email
    self.username = username
    self.password = password
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
