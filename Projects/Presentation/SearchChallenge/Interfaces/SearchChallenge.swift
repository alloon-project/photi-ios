//
//  SearchChallenge.swift
//  SearchChallenge
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

public protocol SearchChallengeContainable: Containable {
  func coordinator(listener: SearchChallengeListener) -> Coordinating
}

public protocol SearchChallengeListener: AnyObject { }
