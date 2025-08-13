//
//  DeletedDateResponseDTO.swift
//  DTO
//
//  Created by jung on 8/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct DeletedDateResponseDTO: Decodable {
  public let deletedDate: String
}

public extension DeletedDateResponseDTO {
  static let stubData = """
    {
      "code": "200 OK",
      "message": "성공",
      "data": {
        "deletedDate": "2025-07-15"
      }
    }
    """
}
