//
//  FeedByDateResponseDTO.swift
//  DTO
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct FeedByDateResponseDTO: Decodable {
  public let feedId: Int
  public let challengeId: Int
  public let imageUrl: String?
  public let name: String
  public let proveTime: String
  // public let isDeleted: Bool /// 추가된 DTO 프로퍼티
}

public extension FeedByDateResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": [
    {
      "feedId": 1,
      "challengeId": 1,
      "imageUrl": "https://url.kr/5MhHhD",
      "name": "신나게 하는 러닝 챌린지",
      "proveTime": "13:00"
    }
  ]
}
"""
}
