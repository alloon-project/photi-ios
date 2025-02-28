//
//  FeedHistoryResponseDTO.swift
//  Data
//
//  Created by 임우섭 on 2/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct FeedHistoryResponseDTO: Decodable {
  public let content: [FeedHistoryContent]
  
  public init(content: [FeedHistoryContent]) {
    self.content = content
  }
}

public struct FeedHistoryContent: Decodable {
  public let feedId: Int
  public let challengeId: String
  public let imageUrl: URL?
  public let createDate: Date
  public let name: String
}

public extension FeedHistoryResponseDTO  {
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
