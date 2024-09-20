//
//  ChallengeViewModel.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

struct ChallengeViewModel {
  enum Mode {
    case `default`
    case create
  }
  
  let name: String
  let mode: Mode
  let image: UIImage?
  let goal: String
  let verificatoinTime: String
  let expirationTime: String
  
  let numberOfPersons: Int
} 
