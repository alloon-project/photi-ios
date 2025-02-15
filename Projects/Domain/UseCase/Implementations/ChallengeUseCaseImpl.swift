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
  private let authRepository: AuthRepository
  
  public init(repository: ChallengeRepository, authRepository: AuthRepository) {
    self.repository = repository
    self.authRepository = authRepository
  }
  
  public func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail> {
    return repository.fetchChallengeDetail(id: id)
  }
  
  public func isLogIn() async -> Bool {
    return await authRepository.isLogIn()
  }
  
  public func joinPrivateChallnege(id: Int, code: String) async throws {
    try await repository.joinPrivateChallnege(id: id, code: code).value
  }
}
