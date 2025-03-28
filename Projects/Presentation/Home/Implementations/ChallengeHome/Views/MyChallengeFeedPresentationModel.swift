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
    case proofURL(_ url: URL?)
    case proofImage(_ image: UIImage)
    case didNotProof
  }
  
  let id: Int
  let title: String
  let deadLine: String
  var type: ModelType
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
