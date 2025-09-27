//
//  Challenge.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Coordinator

public enum ChallengePresentType {
  case `default`
  case presentWithFeed(_ feedId: Int)
}

public protocol ChallengeContainable: Containable {
  func coordinator(
    listener: ChallengeListener,
    challengeId: Int,
    presentType: ChallengePresentType
  ) -> ViewableCoordinating
}

public protocol ChallengeListener: AnyObject {
  func authenticatedFailedAtChallenge()
  func didTapBackButtonAtChallenge()
  func shouldDismissChallenge()
  func leaveChallenge(challengeId: Int)
  func deleteFeed(challengeId: Int, feedId: Int)
}

public extension ChallengeListener {
  func deleteFeed(challengeId: Int, feedId: Int) { }
}
