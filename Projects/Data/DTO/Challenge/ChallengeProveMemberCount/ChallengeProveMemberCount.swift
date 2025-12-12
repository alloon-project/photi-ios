//
//  ChallengeProveMemberCount.swift
//  DTO
//
//  Created by jung on 4/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct ChallengeProveMemberCountResponseDTO: Decodable {
  public let feedMemberCnt: Int
}

public extension ChallengeProveMemberCountResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "feedMemberCnt": 5
  }
}
"""
}
