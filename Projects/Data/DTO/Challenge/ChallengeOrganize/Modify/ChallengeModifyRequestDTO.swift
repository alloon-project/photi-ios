//
//  ChallengeModifyRequestDTO.swift
//  Data
//
//  Created by 임우섭 on 6/6/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeModifyRequestDTO: Encodable {
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
