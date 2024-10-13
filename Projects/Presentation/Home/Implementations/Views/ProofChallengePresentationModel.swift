//
//  ProofChallengePresentationModel.swift
//  HomeImpl
//
//  Created by jung on 10/7/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

struct ProofChallengePresentationModel {
  enum ModelType {
    case proof(image: UIImage)
    case didNotProof
  }
  
  let id: Int
  let title: String
  let deadLine: String
  let type: ModelType
}
