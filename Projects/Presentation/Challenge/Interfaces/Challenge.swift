//
//  Challenge.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

public protocol ChallengeContainable: Containable {
  func coordinator(listener: ChallengeListener, challengeId: Int) -> Coordinating
}

public protocol ChallengeListener: AnyObject { }