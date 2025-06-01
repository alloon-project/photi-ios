//
//  VerifiedChallengeDates.swift
//  DTO
//
//  Created by jung on 6/1/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct VerifiedChallengeDatesResponseDTO: Decodable {
  public let list: [String]
}

public extension VerifiedChallengeDatesResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "list": [
      "string"
    ]
  }
}  
"""
}
