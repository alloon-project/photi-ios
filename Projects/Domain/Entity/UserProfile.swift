//
//  UserProfile.swift
//  Domain
//
//  Created by 임우섭 on 9/26/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct UserProfile {
  public let imageUrl: URL
  public let userName: String
  public let userEmail: String
  
  public static var defaultValue: UserProfile {
    return UserProfile(
      imageUrl: URL(string: "exampleUrl")!,
      userName: "닉네임 불러오는중",
      userEmail: "example@example.com"
    )
  }
  
  public init(
    imageUrl: URL,
    userName: String,
    userEmail: String
  ) {
    self.imageUrl = imageUrl
    self.userName = userName
    self.userEmail = userEmail
  }
}
