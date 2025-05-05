//
//  FeedDetailResponseDTO.swift
//  DTO
//
//  Created by jung on 2/26/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct FeedDetailResponseDTO: Decodable {
  public let username: String
  public let userImageUrl: String?
  public let feedImageUrl: String?
  public let createdDateTime: String
  public let likeCnt: Int
  public let isLike: Bool
}

public extension FeedDetailResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "username": "photi",
    "userImageUrl": "https://fastly.picsum.photos/id/370/200/200.jpg?hmac=HT9dVkM8BnOVYNnQU3Kiehyb9hJUPrehSqcOHXrq_y0",
    "feedImageUrl": "https://fastly.picsum.photos/id/370/200/200.jpg?hmac=HT9dVkM8BnOVYNnQU3Kiehyb9hJUPrehSqcOHXrq_y0",
    "createdDateTime": "2025-02-25T17:11:12.098Z",
    "likeCnt": 10,
    "isLike": true
  }
}
"""
}
