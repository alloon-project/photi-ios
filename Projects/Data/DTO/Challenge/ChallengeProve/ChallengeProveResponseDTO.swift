//
//  ChallengeProveResponseDTO.swift
//  DTO
//
//  Created by jung on 2/25/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct ChallengeProveResponseDTO: Decodable {
  public let isProve: Bool
}

public extension ChallengeProveResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "isProve": true
  }
}
"""
}
