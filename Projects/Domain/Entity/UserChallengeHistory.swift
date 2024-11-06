//
//  UserChallengeHistory.swift
//  Domain
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct UserChallengeHistory {
  public let userName: String
  public let imageUrl: URL?
  public let feedCnt: Int
  public let endedChallengeCnt: Int
  
  public init(
    userName: String,
    imageUrl: URL?,
    feedCnt: Int,
    endedChallengeCnt: Int
  ) {
    self.userName = userName
    self.imageUrl = imageUrl
    self.feedCnt = feedCnt
    self.endedChallengeCnt = endedChallengeCnt
  }
}
