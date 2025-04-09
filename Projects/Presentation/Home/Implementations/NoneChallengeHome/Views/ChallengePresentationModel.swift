//
//  ChallengeViewModel.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

struct ChallengePresentationModel {
  let name: String
  let imageURL: URL?
  let goal: String
  let proveTime: String
  let endDate: String
  let numberOfPersons: Int
  let hashTags: [String]
  let memberImageURLs: [URL]
}
