//
//  FetchInvitaionCodeResponseDTO.swift
//  Data
//
//  Created by wooseob on 9/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct FetchInvitaionCodeResponseDTO: Decodable {
  public let name: String
  public let invitationCode: String
}

public extension FetchInvitaionCodeResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "name": "신나게 하는 러닝 챌린지",
    "invitationCode: "478DS"
  }
}
"""
}
