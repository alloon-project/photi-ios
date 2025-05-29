//
//  ChallengesByHashTagResponseDTO.swift
//  DTO
//
//  Created by jung on 5/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct SearcgChallengesSummaryResponseDTO: Decodable {
  public let content: [SearchChallengeResponseDTO]
  public let page: Int
  public let size: Int
  public let first: Bool
  public let last: Bool
}

public extension SearcgChallengesSummaryResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "content": [
      {
        "id": 1,
        "name": "신나게 하는 러닝 챌린지",
        "imageUrl": "https://url.kr/5MhHhD",
        "endDate": "2024-12-01",
        "hashtags": [
          {
            "hashtag": "러닝"
          },
          {
            "hashtag": "건강"
          }
        ]
      }
    ],
    "page": 0,
    "size": 0,
    "first": true,
    "last": true
  }
}

"""
}
