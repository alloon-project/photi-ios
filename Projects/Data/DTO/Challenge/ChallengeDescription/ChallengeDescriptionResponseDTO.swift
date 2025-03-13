//
//  ChallengeDescriptionResponseDTO.swift
//  DTO
//
//  Created by jung on 3/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeDescriptionResponseDTO: Decodable {
  public let rules: [RuleResponseDTO]
  public let proveTime: String
  public let goal: String
  public let startDate: String
  public let endDate: String
}

public extension ChallengeDescriptionResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
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
    "proveTime": "13:00",
    "goal": "하루에 한 번씩 꼭 러닝을 하는 것이 우리 챌린지의 목표입니다.",
    "startDate": "2024-01-01",
    "endDate": "2024-12-01"
  }
}
"""
}
