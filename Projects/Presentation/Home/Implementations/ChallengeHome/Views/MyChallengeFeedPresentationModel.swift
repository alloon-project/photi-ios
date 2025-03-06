//
//  MyChallengeFeedPresentationModel.swift
//  HomeImpl
//
//  Created by jung on 10/7/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

struct MyChallengeFeedPresentationModel {
  enum ModelType: Equatable {
    case proof(url: URL?)
    case didNotProof
  }
  
  let id: Int
  let title: String
  let deadLine: String
  let type: ModelType
}
