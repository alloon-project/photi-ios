//
//  EndedChallengeResponseDTO.swift
//  Data
//
//  Created by 임우섭 on 11/3/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct EndedChallengeResponseDTO: Decodable {
  public let id: Int
  public let name: String
  public let imageUrl: String?
  public let endDate: String
  public let currentMemberCnt: Int
  public let memberImages: [MemberImageResponseDTO]
}

public extension EndedChallengeResponseDTO {
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
        "currentMemberCnt": 5,
        "memberImages": [
          {
            "memberImage": "https://url.kr/5MhHhD"
          },
          {
            "memberImage": "https://url.kr/5MhHhD"
          },
          {
            "memberImage": "https://url.kr/5MhHhD"
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
