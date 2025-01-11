//
//  FindIdRequestDTO.swift
//  Data
//
//  Created by 임우섭 on 12/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct FindIdRequestDTO: Encodable {
  public let email: String
  
  public init(userEmail: String) {
    self.email = userEmail
  }
}
