//
//  ChallengeOrganizeRequestDTO.swift
//  Data
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeOrganizeRequestDTO: Encodable {
  public let jsonString: String
  public let image: Data
  public let imageType: String
  
  public init(
    jsonString: String,
    image: Data,
    imageType: String
  ) {
    self.jsonString = jsonString
    self.image = image
    self.imageType = imageType
  }
}
