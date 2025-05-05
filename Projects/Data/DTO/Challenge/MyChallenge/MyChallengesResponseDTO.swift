//
//  MyChallengesResponseDTO.swift
//  DTO
//
//  Created by jung on 3/6/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct MyChallengesResponseDTO: Decodable {
  public let content: [MyChallengeResponseDTO]
}

public struct MyChallengeResponseDTO: Decodable {
  public let id: Int
  public let name: String
  public let challengeImageUrl: String?
  public let proveTime: String
  public let endDate: String
  public let hashtags: [HashTagResponseDTO]
  public let feedImageUrl: String?
  public let feedId: Int?
  public let isProve: Bool
}

// swiftlint:disable line_length
public extension MyChallengesResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "content": [
      {
        "id": 1,
        "name": "신나게 하는 러닝 챌린지",
        "challengeImageUrl": "https://fastly.picsum.photos/id/370/200/200.jpg?hmac=HT9dVkM8BnOVYNnQU3Kiehyb9hJUPrehSqcOHXrq_y0",
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
        "feedImageUrl": "https://fastly.picsum.photos/id/370/200/200.jpg?hmac=HT9dVkM8BnOVYNnQU3Kiehyb9hJUPrehSqcOHXrq_y0",
        "isProve": true
      },
      {
        "id": 1,
        "name": "신나게 하는 러닝 챌린지",
        "challengeImageUrl": "https://fastly.picsum.photos/id/370/200/200.jpg?hmac=HT9dVkM8BnOVYNnQU3Kiehyb9hJUPrehSqcOHXrq_y0",
        "proveTime": "16:11 ",
        "endDate": "2024-12-01",
        "hashtags": [
          {
            "hashtag": "러닝"
          },
          {
            "hashtag": "건강"
          }
        ],
        "isProve": false
      },
      {
        "id": 2,
        "name": "신나게 하는 러닝 챌린지",
        "challengeImageUrl": "https://fastly.picsum.photos/id/370/200/200.jpg?hmac=HT9dVkM8BnOVYNnQU3Kiehyb9hJUPrehSqcOHXrq_y0",
        "proveTime": "18:00",
        "endDate": "2024-12-01",
        "hashtags": [
          {
            "hashtag": "러닝"
          },
          {
            "hashtag": "건강"
          }
        ],
        "isProve": false
      },
      {
        "id": 3,
        "name": "신나게 하는 러닝 챌린지",
        "challengeImageUrl": "https://fastly.picsum.photos",
        "proveTime": "18:00",
        "endDate": "2024-12-01",
        "hashtags": [
          {
            "hashtag": "러닝"
          },
          {
            "hashtag": "건강"
          }
        ],
        "feedImageUrl": "https://fastly.picsum.photos/id/370/200/200.jpg?hmac=HT9dVkM8BnOVYNnQU3Kiehyb9hJUPrehSqcOHXrq_y0",
        "isProve": true
      },
      {
        "id": 4,
        "name": "신나게 하는 러닝 챌린지",
        "proveTime": "21:00",
        "endDate": "2024-12-01",
        "hashtags": [
          {
            "hashtag": "러닝"
          },
          {
            "hashtag": "건강"
          }
        ],
        "isProve": false
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
// swiftlint:enable line_length
