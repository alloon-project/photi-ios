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
import Core
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
}

// MARK: - Fetch Methods
public extension ChallengeUseCaseImpl {
  func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail> {
    return repository.fetchChallengeDetail(id: id)
  }
  
  func isLogIn() async -> Bool {
    return await authRepository.isLogIn()
  }
  
  func fetchFeeds(id: Int, page: Int, size: Int, orderType: ChallengeFeedsOrderType) async throws -> PageFeeds {
    let result = try await repository.fetchFeeds(id: id, page: page, size: size, orderType: orderType)
    
    if challengeProveMemberCountRelay.value != result.memberCount {
      challengeProveMemberCountRelay.accept(result.memberCount)
    }
    
    return result.isLast ? .lastPage(result.feeds) : .defaults(result.feeds)
  }
  
  func fetchChallengeDescription(id: Int) -> Single<ChallengeDescription> {
    return repository.fetchChallengeDescription(challengeId: id)
  }
}

// MARK: - Upload & Update Methods
public extension ChallengeUseCaseImpl {
  func joinPrivateChallnege(id: Int, code: String) async throws {
    try await repository.joinPrivateChallnege(id: id, code: code).value
  }
  
  func joinPublicChallenge(id: Int) -> Single<Void> {
    return repository.joinPublicChallenge(id: id)
  }
  
  func uploadChallengeFeedProof(id: Int, image: UIImageWrapper) async throws {
    guard let (data, type) = imageToData(image, maxMB: 8) else {
      throw APIError.challengeFailed(reason: .fileTooLarge)
    }
    
    try await repository.uploadChallengeFeedProof(
      id: id,
      image: data,
      imageType: type
    )
  }
  
  func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws {
    return try await repository.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
  }
  
  func isProve(challengeId: Int) async throws -> Bool {
    return try await repository.isProve(challengeId: challengeId)
  }
  
  func updateChallengeGoal(_ goal: String, challengeId: Int) -> Single<Void> {
    return repository.updateChallengeGoal(goal, challengeId: challengeId)
  }
}

// MARK: - Private Methods
private extension ChallengeUseCaseImpl {
 func imageToData(_ image: UIImageWrapper, maxMB: Int) -> (image: Data, type: String)? {
   let maxSizeBytes = maxMB * 1024 * 1024
   
   if let data = image.image.pngData(), data.count <= maxSizeBytes {
     return (data, "png")
   } else if let data = image.image.converToJPEG(maxSizeMB: 8) {
     return (data, "jpeg")
   }
   return nil
 }
}
