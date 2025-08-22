//
//  AppVersionResponseDTO.swift
//  DTO
//
//  Created by jung on 8/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct AppVersionResponseDTO: Decodable {
  public let forceUpdate: Bool
}

public extension AppVersionResponseDTO {
  static let stubData = """
    {
      "code": "200 OK",
      "message": "성공",
      "data": {
        "forceUpdate": true
      }
    }
    """
}
