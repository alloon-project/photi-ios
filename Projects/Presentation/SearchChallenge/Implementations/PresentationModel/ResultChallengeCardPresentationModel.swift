//
//  ResultChallengeCardPresentationModel.swift
//  HomeImpl
//
//  Created by jung on 5/24/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

struct ResultChallengeCardPresentationModel: Hashable {
  let id: Int
  let hashTags: [String]
  let title: String
  let imageUrl: URL?
  let deadLine: String
  let memberCount: Int
  let memberImageUrls: [URL]
}
