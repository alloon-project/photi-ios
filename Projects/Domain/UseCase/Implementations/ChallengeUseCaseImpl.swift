//
//  ChallengeUseCaseImpl.swift
//  Entity
//
//  Created by jung on 1/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity
import UseCase
import Repository

public struct ChallengeUseCaseImpl: ChallengeUseCase {
  private let repository: ChallengeRepository
  
  public init(repository: ChallengeRepository) {
    self.repository = repository
  }
  
  public func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail> {
    return repository.fetchChallengeDetail(id: id)
  }
}
