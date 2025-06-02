//
//  FeedHistoryResponseDTO.swift
//  Data
//
//  Created by 임우섭 on 2/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct FeedHistoryResponseDTO: Decodable {
  public let feedId: Int
  public let challengeId: Int
  public let imageUrl: String?
  public let createdDate: String
  public let name: String
  public let invitationCode: String
}

public extension FeedHistoryResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "content": [
      {
        "feedId": 1,
        "challengeId": 1,
        "imageUrl": "https://url.kr/5MhHhD",
        "createdDate": "2024-10-23",
        "name": "신나게 하는 러닝 챌린지"
      },
      {
        "feedId": 1,
        "challengeId": 1,
        "imageUrl": "https://url.kr/5MhHhD",
        "createdDate": "2024-10-23",
        "name": "신나게 하는 러닝 챌린지"
      },
      {
        "feedId": 1,
        "challengeId": 1,
        "imageUrl": "https://url.kr/5MhHhD",
        "createdDate": "2024-10-23",
        "name": "신나게 하는 러닝 챌린지"
      },
      {
        "feedId": 1,
        "challengeId": 1,
        "imageUrl": "https://url.kr/5MhHhD",
        "createdDate": "2024-10-23",
        "name": "신나게 하는 러닝 챌린지"
      },
      {
        "feedId": 1,
        "challengeId": 1,
        "imageUrl": "https://url.kr/5MhHhD",
        "createdDate": "2024-10-23",
        "name": "신나게 하는 러닝 챌린지"
      },
      {
        "feedId": 1,
        "challengeId": 1,
        "imageUrl": "https://url.kr/5MhHhD",
        "createdDate": "2024-10-23",
        "name": "신나게 하는 러닝 챌린지"
      },
      {
        "feedId": 1,
        "challengeId": 1,
        "imageUrl": "https://url.kr/5MhHhD",
        "createdDate": "2024-10-23",
        "name": "신나게 하는 러닝 챌린지"
      },
      {
        "feedId": 1,
        "challengeId": 1,
        "imageUrl": "https://url.kr/5MhHhD",
        "createdDate": "2024-10-23",
        "name": "신나게 하는 러닝 챌린지"
      },
      {
        "feedId": 1,
        "challengeId": 1,
        "imageUrl": "https://url.kr/5MhHhD",
        "createdDate": "2024-10-23",
        "name": "신나게 하는 러닝 챌린지"
      },
      {
        "feedId": 1,
        "challengeId": 1,
        "imageUrl": "https://url.kr/5MhHhD",
        "createdDate": "2024-10-23",
        "name": "신나게 하는 러닝 챌린지"
      },
    ],
    "page": 0,
    "size": 10,
    "first": true,
    "last": false
  }
}
"""
}
