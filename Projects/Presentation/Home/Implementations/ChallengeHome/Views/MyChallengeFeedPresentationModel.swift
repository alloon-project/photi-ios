//
//  MyChallengeFeedPresentationModel.swift
//  HomeImpl
//
//  Created by jung on 10/7/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

struct MyChallengeFeedPresentationModel: Hashable {
  enum ModelType: Equatable {
    case didProof(_ url: URL?, feedId: Int)
    case didNotProof
  }
  
  let challengeId: Int
  let title: String
  let deadLine: String
  var type: ModelType
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(challengeId)
  }
}
