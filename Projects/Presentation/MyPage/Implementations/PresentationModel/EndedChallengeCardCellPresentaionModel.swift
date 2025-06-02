//
//  EndedChallengeCardCellPresentaionModel.swift
//  Presentation
//
//  Created by wooseob on 12/17/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct EndedChallengeCardCellPresentationModel {
  let challengeImageUrl: URL?
  let challengeTitle: String
  let endedDate: String
  let challengeId: Int
  let currentMemberCnt: Int
  let challengeParticipantImageUrls: [URL]
  
  public init(
    challengeImageUrl: URL?,
    challengeTitle: String,
    endedDate: String,
    challengeId: Int,
    currentMemberCnt: Int,
    challengeParticipantImageUrls: [URL]
  ) {
    self.challengeImageUrl = challengeImageUrl
    self.challengeTitle = challengeTitle
    self.endedDate = endedDate
    self.challengeId = challengeId
    self.currentMemberCnt = currentMemberCnt
    self.challengeParticipantImageUrls = challengeParticipantImageUrls
  }
}
