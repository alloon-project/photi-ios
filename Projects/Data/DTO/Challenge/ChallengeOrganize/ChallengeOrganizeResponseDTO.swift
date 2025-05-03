//
//  ChallengeOrganizeResponseDTO.swift
//  Data
//
//  Created by 임우섭 on 5/3/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeOrganizeResponseDTO: Decodable {
  public let id: Int
  public let name: String
  public let goal: String
  public let proveTime: String
  public let endDate: String
  public let imageUrl: String
  public let rules: [String]
  public let hashtags: [String]
  
  public init(
    id: Int,
    name: String,
    goal: String,
    proveTime: String,
    endDate: String,
    imageUrl: String,
    rules: [String],
    hashtags: [String]
  ) {
    self.id = id
    self.name = name
    self.goal = goal
    self.proveTime = proveTime
    self.endDate = endDate
    self.imageUrl = imageUrl
    self.rules = rules
    self.hashtags = hashtags
  }
}

public extension ChallengeOrganizeResponseDTO {
  static let stubData = """
{
  "code": "201 CREATED",
  "message": "성공",
  "data": {
    "id": 1,
    "name": "신나게 하는 러닝 챌린지",
    "goal": "하루에 한 번씩 꼭 러닝을 하는 것이 우리 챌린지의 목표입니다.",
    "proveTime": "13:00",
    "endDate": "2024-12-01",
    "imageUrl": "https://url.kr/5MhHhD",
    "rules": [
      {
        "rule": "장소 나오게 찍기"
      },
      {
        "rule": "일주일에 3회 이상 인증하기"
      },
      {
        "rule": "얼굴 안 나오게 찍기"
      }
    ],
    "hashtags": [
      {
        "hashtag": "러닝"
      },
      {
        "hashtag": "건강"
      }
    ]
  }
}
"""
}
