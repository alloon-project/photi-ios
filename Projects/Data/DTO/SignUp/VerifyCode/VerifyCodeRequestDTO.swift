//
//  VerifyCodeRequestDTO.swift
//  DTO
//
//  Created by jung on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct VerifyCodeRequestDTO: Encodable {
  public let email: String
  public let code: String
  
  enum CodingKeys: String, CodingKey {
    case email
    case code = "verificationCode"
  }
  
  public init(email: String, code: String) {
    self.email = email
    self.code = code
  }
}

extension VerifyCodeRequestDTO {
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
