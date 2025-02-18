//
//  ChallengeUseCase.swift
//  Entity
//
//  Created by jung on 1/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity

public protocol ChallengeUseCase {
  func isLogIn() async -> Bool
  func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail>
  func joinPrivateChallnege(id: Int, code: String) async throws
}
