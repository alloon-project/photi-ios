//
//  HomeUseCaseImpl.swift
//  UseCaseImpl
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Entity
import UseCase
import Repository

public struct HomeUseCaseImpl: HomeUseCase {
  private let repository: ChallengeRepository
  
  public init(repository: ChallengeRepository) {
    self.repository = repository
  }
  
  public func fetchPopularChallenge() -> Single<[ChallengeDetail]> {
    return repository.fetchPopularChallenges()
  }
}
