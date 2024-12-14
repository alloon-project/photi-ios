//
//  EndedChallengeUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 11/3/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Entity
import UseCase
import Repository

public struct EndedChallengeUseCaseImpl: EndedChallengeUseCase {
  private let repository: EndedChallengeRepository
  
  public init(repository: EndedChallengeRepository) {
    self.repository = repository
  }
  
  public func endedChallenges(page: Int, size: Int) -> Single<[EndedChallenge]> {
    return repository.endedChallenges(page: page, size: size)
  }
}
