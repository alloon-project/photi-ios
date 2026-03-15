//
//  OAuthUsernameRequestDTO.swift
//  Data
//
//  Created by Claude on 3/15/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

public struct OAuthUsernameRequestDTO: Encodable {
  public let username: String

  public init(username: String) {
    self.username = username
  }
}
