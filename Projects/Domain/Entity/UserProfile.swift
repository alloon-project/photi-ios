//
//  UserProfile.swift
//  Domain
//
//  Created by 임우섭 on 9/26/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct UserProfile {
  public let imageUrl: URL?
  public let name: String
  public let email: String
  
  public init(
    imageUrl: URL?,
    name: String,
    email: String
  ) {
    self.imageUrl = imageUrl
    self.name = name
    self.email = email
  }
}
