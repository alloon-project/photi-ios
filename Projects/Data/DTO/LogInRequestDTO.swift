//
//  LogInRequestDTO.swift
//  DTO
//
//  Created by jung on 8/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct LogInRequestDTO: Encodable {
  public let username: String
  public let password: String
  
  public init(username: String, password: String) {
    self.username = username
    self.password = password
  }
}

#if DEBUG
extension LogInRequestDTO {
  public static let stubData =
 """
 {
 "code": "FAIL",
 "message": "FAIL",
 }
 """
}
#endif
