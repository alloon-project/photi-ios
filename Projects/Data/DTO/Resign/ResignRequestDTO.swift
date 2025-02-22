//
//  ResignRequestDTO.swift
//  Data
//
//  Created by 임우섭 on 2/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct ResignRequestDTO: Encodable {
  public let password: String
  
  public init(password: String) {
    self.password = password
  }
}

public extension ResignRequestDTO {
  static let stubData = """
  {
    "code": "200 OK",
    "message": "성공",
    "data": {
      "successMessage": "성공"
    },
  }
"""
}
