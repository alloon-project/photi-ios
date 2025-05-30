//
//  SearchChallengeResponseDTO.swift
//  DTO
//
//  Created by jung on 5/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct SearchChallengeResponseDTO: Decodable {
  public let id: Int
  public let name: String
  public let imageUrl: String?
  public let endDate: String
  public let hashtags: [HashTagResponseDTO]
}

public extension SearchChallengeResponseDTO {
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
