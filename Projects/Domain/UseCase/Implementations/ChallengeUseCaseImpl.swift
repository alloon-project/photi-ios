//
//  ChallengeUseCaseImpl.swift
//  Entity
//
//  Created by jung on 1/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import Entity
import UseCase
import Repository

public struct ChallengeUseCaseImpl: ChallengeUseCase {
  private let repository: ChallengeRepository
  private let authRepository: AuthRepository
  private let challengeProveMemberCountRelay = BehaviorRelay<Int>(value: 0)
  public let challengeProveMemberCount: Infallible<Int>
  
  public init(repository: ChallengeRepository, authRepository: AuthRepository) {
    self.repository = repository
    self.authRepository = authRepository
    
    self.challengeProveMemberCount = challengeProveMemberCountRelay.asInfallible()
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
  
  public func fetchFeeds(id: Int, page: Int, size: Int, orderType: ChallengeFeedsOrderType) async throws -> PageFeeds {
    let result = try await repository.fetchFeeds(id: id, page: page, size: size, orderType: orderType)
    
    if challengeProveMemberCountRelay.value != result.memberCount {
      challengeProveMemberCountRelay.accept(result.memberCount)
    }
    
    return result.isLast ? .lastPage(result.feeds) : .defaults(result.feeds)
  }
  
  public func uploadChallengeFeedProof(id: Int, image: Data) async throws {
    return try await repository.uploadChallengeFeedProof(id: id, image: image)
  }
  
  public func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws {
    return try await repository.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
  }
  
  public func isProof() async -> Bool {
    // TODO: - API 나온 후 적용할 예정
    return false
  }
}
