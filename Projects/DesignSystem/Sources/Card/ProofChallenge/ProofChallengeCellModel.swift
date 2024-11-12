//
//  ProofChallengeCellModel.swift
//  DesignSystem
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

public struct ProofChallengeCellPresentationModel {
  let challengeImage: URL?
  let challengeTitle: String
  let finishedDate: Date
  let challengeId: String
  
  init(
    challengeImage: URL?,
    challengeTitle: String,
    finishedDate: Date,
    challengeId: String
  ) {
    self.challengeImage = challengeImage
    self.challengeTitle = challengeTitle
    self.finishedDate = finishedDate
    self.challengeId = challengeId
  }
}
