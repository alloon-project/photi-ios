//
//  EndedChallengeRequestDTO.swift
//  Data
//
//  Created by 임우섭 on 11/3/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct EndedChallengeRequestDTO: Encodable {
  public let page: Int
  public let size: Int
  
  public init(
    page: Int,
    size: Int
  ) {
    self.page = page
    self.size = size
  }
}
