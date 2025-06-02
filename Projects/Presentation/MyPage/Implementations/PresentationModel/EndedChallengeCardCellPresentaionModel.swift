//
//  EndedChallengeCardCellPresentaionModel.swift
//  Presentation
//
//  Created by wooseob on 12/17/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

struct EndedChallengeCardPresentationModel: Hashable {
  let id: Int
  let thumbnailUrl: URL?
  let title: String
  let deadLine: String
  let currentMemberCnt: Int
  let memberImageUrls: [URL]
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
