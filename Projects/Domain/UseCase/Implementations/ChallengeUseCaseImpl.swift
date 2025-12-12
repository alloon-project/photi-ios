//
//  ChallengeUseCaseImpl.swift
//  Entity
//
//  Created by jung on 1/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core
import Entity
import UseCase
import Repository

public struct ChallengeUseCaseImpl: ChallengeUseCase {
  private let maximumChallengeCount = 20
  
  private let challengeRepository: ChallengeRepository
  private let feedRepository: FeedRepository
  private let authRepository: AuthRepository
  private let imageUploader: PresignedImageUploader
  
  public init(
    challengeRepository: ChallengeRepository,
    feedRepository: FeedRepository,
    authRepository: AuthRepository,
    imageUploader: PresignedImageUploader
  ) {
    self.challengeRepository = challengeRepository
    self.feedRepository = feedRepository
    self.authRepository = authRepository
    self.imageUploader = imageUploader
  }
}

// MARK: - Fetch Methods
public extension ChallengeUseCaseImpl {
  func fetchChallengeDetail(id: Int) async throws -> ChallengeDetail {
    return try await challengeRepository.fetchChallengeDetail(id: id)
  }
  
  func isLogIn() async throws -> Bool {
    return try await authRepository.isLogIn()
  }
  
  func fetchFeeds(id: Int, page: Int, size: Int, orderType: ChallengeFeedsOrderType) async throws -> PageState<[Feed]> {
    let result = try await feedRepository.fetchFeeds(id: id, page: page, size: size, orderType: orderType)
    
    return result.isLast ? .lastPage(result.feeds) : .defaults(result.feeds)
  }
  
  func fetchChallengeDescription(id: Int) async throws -> ChallengeDescription {
    return try await challengeRepository.fetchChallengeDescription(challengeId: id)
  }
  
  func fetchChallengeMembers(challengeId: Int) async throws -> [ChallengeMember] {
    return try await challengeRepository.fetchChallengeMembers(challengeId: challengeId)
  }
  
  func challengeProveMemberCount(challengeId: Int) async throws -> Int {
    return try await challengeRepository.challengeProveMemberCount(challengeId: challengeId)
  }
  
  func isPossibleToJoinChallenge() async -> Bool {
    let myChallengeCount = try? await challengeRepository.fetchMyChallenges(page: 0, size: 20)
      .count
    
    guard let myChallengeCount else { return true }
    
    return myChallengeCount < maximumChallengeCount
  }
  
  func isJoinedChallenge(id: Int) async -> Bool {
    let myChallenges = try? await challengeRepository.fetchMyChallenges(page: 0, size: 20)
      .map { $0.id }
    guard let myChallenges else { return false }
    return myChallenges.contains(id)
  }
}

// MARK: - Upload & Update Methods
public extension ChallengeUseCaseImpl {
  func fetchInvitationCode(id: Int) async throws -> ChallengeInvitation {
    return try await challengeRepository.fetchInvitationCode(id: id)
  }
  
  func verifyInvitationCode(id: Int, code: String) async throws -> Bool {
    return try await challengeRepository.verifyInvitationCode(id: id, code: code)
  }
  
  func joinChallenge(id: Int, goal: String) async throws {
    return try await challengeRepository.joinChallenge(id: id, goal: goal)
  }
  
  func uploadChallengeFeedProof(id: Int, image: UIImageWrapper) async throws -> Feed {
    guard let (data, type) = imageToData(image, maxMB: 8) else {
      throw APIError.challengeFailed(reason: .fileTooLarge)
    }
    let imgType = ImageType(rawValue: type) ?? .jpeg
    let url = try await imageUploader.upload(image: data, imageType: imgType)
    
    return try await challengeRepository.uploadChallengeFeedProof(id: id, imageUrl: url)
  }
  
  func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws {
    return try await feedRepository.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
  }
  
  func isProve(challengeId: Int) async throws -> Bool {
    return try await challengeRepository.isProve(challengeId: challengeId)
  }
  
  func updateChallengeGoal(_ goal: String, challengeId: Int) async throws {
    return try await challengeRepository.updateChallengeGoal(goal, challengeId: challengeId)
  }
}

// MARK: - Delete Methods
public extension ChallengeUseCaseImpl {
  func leaveChallenge(id: Int) async throws {
    return try await challengeRepository.leaveChallenge(id: id)
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
