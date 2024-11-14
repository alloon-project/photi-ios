//
//  FindPasswordRequestDTO.swift
//  Data
//
//  Created by wooseob on 11/13/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct FindPasswordRequestDTO: Encodable {
  public let userEmail: String
  public let userName: String
  
  public init(userEmail: String, userName: String) {
    self.userEmail = userEmail
    self.userName = userName
  }
}
