//
//  PopularChallengeResponseDTO.swift
//  DTO
//
//  Created by jung on 1/29/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct PopularChallengeResponseDTO: Decodable {
  public let id: Int
  public let name: String
  public let imageUrl: URL?
  public let goal: String
  public let currentMemberCnt: Int
  public let proveTime: String
  public let endDate: String
  public let hashtags: [HashTagResponseDTO]
  public let memberImages: [MemberImageResponseDTO]
}

public extension PopularChallengeResponseDTO {
  static let stubData = """
  {
    "code": "200 OK",
    "message": "성공",
    "data": [
      {
        "id": 1,
        "name": "신나게 하는 러닝 챌린지",
        "imageUrl": "https://url.kr/5MhHhD",
        "goal": "하루에 한 번씩 꼭 러닝을 하는 것이 우리 챌린지의 목표입니다.",
        "proveTime": "13:00",
        "endDate": "2024-12-01",
        "hashtags": [
          {
            "hashtag": "러닝"
          },
          {
            "hashtag": "건강"
          }
        ],
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
    ]
  }
"""
}
