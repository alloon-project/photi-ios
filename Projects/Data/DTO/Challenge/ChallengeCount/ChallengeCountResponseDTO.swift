//
//  ChallengeCountResponseDTO.swift
//  DTO
//
//  Created by jung on 4/8/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct ChallengeCountResponseDTO: Decodable {
  public let username: String
  public let challengeCnt: Int
}

public extension ChallengeCountResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "username": "photi",
    "challengeCnt": 5
  }
}
"""
}
