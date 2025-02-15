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
  private let repository: ChallengeRepository
  
  public init(repository: ChallengeRepository) {
    self.repository = repository
  }
  
  public func fetchEndedChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]> {
    return repository.fetchEndedChallenges(page: page, size: size)
  }
}
