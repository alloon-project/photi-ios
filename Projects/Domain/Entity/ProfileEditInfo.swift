//
//  ProfileEditInfo.swift
//  Domain
//
//  Created by 임우섭 on 9/26/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct ProfileEditInfo {
  public let imageUrl: String
  public let userName: String
  public let userEmail: String
  
  public init(
    imageUrl: String,
    userName: String,
    userEmail: String
  ) {
    self.imageUrl = imageUrl
    self.userName = userName
    self.userEmail = userEmail
  }
}
