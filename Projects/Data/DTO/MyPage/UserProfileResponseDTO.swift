//
//  ProfileEditResponseDTO.swift
//  DTO
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct UserProfileResponseDTO: Decodable {
  public let imageUrl: String?
  public let username: String
  public let email: String
}

public extension UserProfileResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "imageUrl": "https://url.kr/5MhHhD",
    "username": "photi",
    "email": "photi@photi.com"
  }
}
"""
}
