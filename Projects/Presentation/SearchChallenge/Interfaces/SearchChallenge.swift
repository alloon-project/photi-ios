//
//  SearchChallenge.swift
//  SearchChallenge
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator

public protocol SearchChallengeContainable: Containable {
  func coordinator(listener: SearchChallengeListener) -> ViewableCoordinating
}

public protocol SearchChallengeListener: AnyObject {
  func authenticatedFailedAtSearchChallenge()
  func attachLoginPopup()
  func didLoginAtSearchChallenge()
}

public protocol SearchChallengeDeepLinkable: AnyObject {
  @MainActor func routeToChallenge(challengeId: Int)
}
