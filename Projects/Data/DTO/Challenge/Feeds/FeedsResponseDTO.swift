//
//  FeedsResponseDTO.swift
//  DTO
//
//  Created by jung on 2/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct FeedsResponseDTO: Decodable {
  public let content: [ContentResponseDTO]
  public let page: Int
  public let size: Int
  public let first: Bool
  public let last: Bool
}

public struct ContentResponseDTO: Decodable {
  public let createdDate: String
  public let feedMemberCnt: Int
  public let feeds: [FeedResponseDTO]
}

public struct FeedResponseDTO: Decodable {
  public let id: Int
  public let username: String
  public let imageUrl: URL
  public let createdDateTime: String
  public let proveTime: String
  public let isLike: Bool
}

public extension FeedsResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "content": [
      {
        "createdDate": "2025-02-23",
        "feedMemberCnt": 5,
        "feeds": [
          {
            "id": 1,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2025-02-23T11:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          },
          {
            "id": 2,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2025-02-23T11:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          }
        ]
      },
      {
        "createdDate": "2025-02-21",
        "feedMemberCnt": 5,
        "feeds": [
          {
            "id": 3,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2025-02-21T11:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          },
          {
            "id": 4,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2025-02-21T11:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          },
          {
            "id": 5,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2025-02-21T11:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          },
          {
            "id": 6,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2025-02-21T11:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          },
          {
            "id": 7,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2025-02-21T11:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          }
        ]
      },
      {
        "createdDate": "2025-02-29",
        "feedMemberCnt": 5,
        "feeds": [
          {
            "id": 8,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2025-02-19T10:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          }
        ]
      },    
      {
        "createdDate": "2025-01-21",
        "feedMemberCnt": 5,
        "feeds": [
          {
            "id": 10,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2025-01-21T10:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          }
        ]
      },
      {
        "createdDate": "2024-02-21",
        "feedMemberCnt": 5,
        "feeds": [
          {
            "id": 9,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2024-02-21T15:10:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          }
        ]
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
        "createdDate": "2023-02-23",
        "feedMemberCnt": 5,
        "feeds": [
          {
            "id": 10,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2023-02-23T11:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          },
          {
            "id": 11,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2023-02-23T11:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          }
        ]
      }       
    ],
    "page": 0,
    "size": 0,
    "first": false,
    "last": false
  }
}
"""
  
  static let stubData3 = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "content": [
      {
        "createdDate": "2022-02-23",
        "feedMemberCnt": 5,
        "feeds": [
          {
            "id": 10,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2022-02-23T11:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          },
          {
            "id": 11,
            "username": "photi",
            "imageUrl": "https://url.kr/5MhHhD",
            "createdDateTime": "2022-02-23T11:16:40.778Z",
            "proveTime": "13:00",
            "isLike": true
          }
        ]
      }       
    ],
    "page": 0,
    "size": 0,
    "first": false,
    "last": true
  }
}
"""
}
