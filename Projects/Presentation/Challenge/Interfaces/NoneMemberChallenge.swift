//
//  NoneMemberChallenge.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

public protocol NoneMemberChallengeListener: AnyObject { }

public protocol NoneMemberChallengeContainable: Containable {
  func coordinator(listener: NoneMemberChallengeListener) -> ViewableCoordinating
}
