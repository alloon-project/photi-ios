//
//  FeedCommentsResponseDTO.swift
//  DTO
//
//  Created by jung on 2/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct FeedCommentsResponseDTO: Decodable {
  public let content: [CommentResponseDTO]
  public let last: Bool
}

public struct CommentResponseDTO: Decodable {
  public let id: Int
  public let username: String
  public let comment: String
}

public extension FeedCommentsResponseDTO {
  static let stubData1 = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "content": [
      {
        "id": 1,
        "username": "photi",
        "comment": "멋져요"
      },
      {
        "id": 2,
        "username": "석영",
        "comment": "멋져요"
      },
      {
        "id": 3,
        "username": "우섭",
        "comment": "멋져요"
      },
      {
        "id": 4,
        "username": "photi",
        "comment": "멋져요"
      },
      {
        "id": 5,
        "username": "photi",
        "comment": "멋져요"
      },
      {
        "id": 6,
        "username": "photi",
        "comment": "멋져요!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      }
    ],
    "page": 0,
    "size": 0,
    "first": true,
    "last": false
  }
}
"""
  
  static let stubData2 = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "content": [
      {
        "id": 7,
        "username": "photi",
        "comment": "멋져요"
      },
      {
        "id": 8,
        "username": "석영",
        "comment": "멋져요"
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
