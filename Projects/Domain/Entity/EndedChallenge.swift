//
//  EndedChallenge.swift
//  Entity
//
//  Created by 임우섭 on 11/3/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct EndedChallenge {
  public let id: Int
  public let name: String
  public let imageUrl: URL?
  public let endDate: Date
  public let currentMemberCnt: Int
  public let memberImages: [URL?]
  
  public init(
    id: Int,
    name: String,
    imageUrl: URL?,
    endDate: Date,
    currentMemberCnt: Int,
    memberImages: [URL?]
  ) {
    self.id = id
    self.name = name
    self.imageUrl = imageUrl
    self.endDate = endDate
    self.currentMemberCnt = currentMemberCnt
    self.memberImages = memberImages
  }
}
