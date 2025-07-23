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

extension LogInRequestDTO {
  public static let stubData =
 """
 {
   "code": "200 OK",
   "message": "성공",
   "data": {
     "userId": 1,
     "username": "photi",
     "imageUrl": "https://url.kr/5MhHhD",
     "temporaryPasswordYn": true
   }
 }
 """
}
