//
//  FindPasswordRequestDTO.swift
//  Data
//
//  Created by wooseob on 11/13/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct FindPasswordRequestDTO: Encodable {
  public let email: String
  public let username: String
  
  public init(email: String, username: String) {
    self.email = email
    self.username = username
  }
}
