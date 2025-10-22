//
//  HomeUseCaseImpl.swift
//  UseCaseImpl
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import Entity
import UseCase
import Repository

public struct HomeUseCaseImpl: HomeUseCase {
  private let challengeRepository: ChallengeRepository
  
  public init(challengeRepository: ChallengeRepository) {
    self.challengeRepository = challengeRepository
  }
  
  public func challengeCount() async throws -> Int {
    return try await challengeRepository.challengeCount()
  }
  
  public func fetchPopularChallenge() async throws -> [ChallengeDetail] {
    return try await challengeRepository.fetchPopularChallenges()
  }
  
  public func fetchMyChallenges() async throws -> [ChallengeSummary] {
    return try await challengeRepository.fetchMyChallenges(page: 0, size: 20)
  }
  
  public func uploadChallengeFeed(challengeId: Int, image: UIImageWrapper) async throws -> Feed {
    guard let (data, type) = imageToData(image, maxMB: 8) else {
      throw APIError.challengeFailed(reason: .fileTooLarge)
    }
    
    return try await challengeRepository.uploadChallengeFeedProof(
      id: challengeId,
      image: data,
      imageType: type
    )
  }
}

private extension HomeUseCaseImpl {
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
