//
//  ChallengeTitlePresentationModel.swift
//  HomeImpl
//
//  Created by jung on 12/10/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

struct ChallengeTitlePresentationModel {
  let title: String
  let hashTags: [String]
  let imageURL: URL?
  
  static let `default` = ChallengeTitlePresentationModel(title: "", hashTags: [], imageURL: nil)
}
