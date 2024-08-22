//
//  RequestVerificationCodeReqeustDTO.swift
//  DTO
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct RequestVerificationCodeReqeustDTO: Encodable {
  public let email: String
  
  public init(email: String) {
    self.email = email
  }
}

#if DEBUG
extension RequestVerificationCodeReqeustDTO {
  public static let stubData =
 """
 {
 "code": "FAIL",
 "message": "FAIL",
 }
 """
}
#endif
