//
//  UserChallengeHistoryDTO.swift
//  Data
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct UserChallengeHistoryResponseDTO: Decodable {
  public let userName: String
  public let imageUrl: URL?
  public let feedCnt: Int
  public let endedChallengeCnt: Int
  
  public init(userName: String, imageUrl: URL?, feedCnt: Int, endedChallengeCnt: Int) {
    self.userName = userName
    self.imageUrl = imageUrl
    self.feedCnt = feedCnt
    self.endedChallengeCnt = endedChallengeCnt
  }
}

public extension UserChallengeHistoryResponseDTO  {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "username": "photi",
    "imageUrl": "https://url.kr/5MhHhD",
    "feedCnt": 99,
    "endedChallengeCnt": 2
  }
}
"""
}
