//
//  VerifyInvitationCodeResponseDTO.swift
//  DTO
//
//  Created by jung on 5/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct VerifyInvitationCodeResponseDTO: Decodable {
  public let isMatch: Bool
}

public extension VerifyInvitationCodeResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "isMatch": true
  }
}
"""
}
