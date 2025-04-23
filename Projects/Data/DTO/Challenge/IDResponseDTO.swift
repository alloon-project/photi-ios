//
//  IDResponseDTO.swift
//  DTO
//
//  Created by jung on 3/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct IDResponseDTO: Decodable {
  public let id: Int
}

public extension IDResponseDTO {
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
