//
//  ChallengeDetailResponseDTO.swift
//  DTO
//
//  Created by jung on 1/29/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeDetailResponseDTO: Decodable {
  public let name: String
  public let goal: String
  public let imageUrl: URL?
  public let currentMemberCnt: Int
  public let isPublic: Bool
  public let proveTime: String
  public let endDate: String
  public let hashtags: [HashTagResponseDTO]
  public let rules: [RuleResponseDTO]
  public let memberImages: [MemberImageResponseDTO]
}

public extension ChallengeDetailResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "name": "신나게 하는 러닝 챌린지",
    "goal": "하루에 한 번씩 꼭 러닝을 하는 것이 우리 챌린지의 목표입니다.",
    "imageUrl": "https://url.kr/5MhHhD",
    "currentMemberCnt": 5,
    "isPublic": true,
    "proveTime": "13:00",
    "endDate": "2024-12-01",
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
}
"""
}
