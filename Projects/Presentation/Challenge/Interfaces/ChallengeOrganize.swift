//
//  ChallengeOrganize.swift
//  Presentation
//
//  Created by 임우섭 on 4/12/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator

public protocol ChallengeOrganizeContainable: Containable {
  func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: ChallengeOrganizeListener
  ) -> Coordinator
}

public protocol ChallengeOrganizeListener: AnyObject {
  func didTapBackButtonAtChallengeOrganize()
  func didOrganizedChallenge(challengeId: Int)
}
