//
//  OAuthWithdrawRequestDTO.swift
//  Data
//
//  Created by Claude on 5/10/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

public struct OAuthWithdrawRequestDTO: Encodable {
  public let provider: String
  public let sub: String

  public init(provider: String, sub: String) {
    self.provider = provider
    self.sub = sub
  }
}
