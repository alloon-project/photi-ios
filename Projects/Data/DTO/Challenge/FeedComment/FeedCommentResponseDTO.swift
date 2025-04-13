//
//  FeedCommentResponseDTO.swift
//  DTO
//
//  Created by jung on 3/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct FeedCommentResponseDTO: Decodable {
  public let id: Int
}

public extension FeedCommentResponseDTO {
  static let stubData = """
{
  "code": "201 CREATED",
  "message": "성공",
  "data": {
    "id": 1
  }
}
"""
}
