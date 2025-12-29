//
//  ChallengeInvitation.swift
//  Domain
//
//  Created by wooseob on 9/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeInvitation {
  public let name: String
  public let invitationCode: String
  
  public init(
    name: String,
    invitationCode: String,
  ) {
    self.name = name
    self.invitationCode = invitationCode
  }
}
