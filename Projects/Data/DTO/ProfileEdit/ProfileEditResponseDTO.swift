//
//  ProfileEditResponseDTO.swift
//  DTO
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct ProfileEditResponseDTO: Decodable {
  public let imageUrl: URL
  public let userName: String
  public let userEmail: String
  
  public init(imageUrl: URL, userName: String, userEmail: String) {
    self.imageUrl = imageUrl
    self.userName = userName
    self.userEmail = userEmail
  }
}
