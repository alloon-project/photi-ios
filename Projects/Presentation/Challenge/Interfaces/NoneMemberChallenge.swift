//
//  NoneMemberChallenge.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

public protocol NoneMemberChallengeContainable: Containable {
  func coordinator(listener: NoneMemberChallengeListener, challengeId: Int) -> ViewableCoordinating
}

public protocol NoneMemberChallengeListener: AnyObject { }
