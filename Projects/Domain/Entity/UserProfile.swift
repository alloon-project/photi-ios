//
//  UserProfile.swift
//  Domain
//
//  Created by 임우섭 on 9/26/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public enum AuthProvider: String {
  case normal
  case kakao = "KAKAO"
  case google = "GOOGLE"
  case apple = "APPLE"
}

public enum WithdrawCredential {
  case password(String)
  case oauth(provider: AuthProvider)
}

public struct UserProfile {
  public let imageUrl: URL?
  public let name: String
  public let email: String
  public let provider: AuthProvider

  public init(
    imageUrl: URL?,
    name: String,
    email: String,
    provider: AuthProvider
  ) {
    self.imageUrl = imageUrl
    self.name = name
    self.email = email
    self.provider = provider
  }
}
