//
//  EndedChallengeUseCase.swift
//  Domain
//
//  Created by 임우섭 on 11/3/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Entity
import Repository

public protocol EndedChallengeUseCase {
  init(repository: EndedChallengeRepository)
  
  func endedChallenges(page: Int, size: Int) -> Single<[EndedChallenge]>
}
