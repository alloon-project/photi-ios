//
//  HomeUseCaseImpl.swift
//  UseCaseImpl
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Entity
import UseCase
import Repository

public struct HomeUseCaseImpl: HomeUseCase {
  private let challengeRepository: ChallengeRepository
  private let imageUploader: PresignedImageUploader
  
  public init(challengeRepository: ChallengeRepository, imageUploader: PresignedImageUploader) {
    self.challengeRepository = challengeRepository
    self.imageUploader = imageUploader
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
  
  public func uploadChallengeFeed(challengeId: Int, imageData: Data, type: String) async throws -> Feed {
    let imgType = ImageType(rawValue: type) ?? .jpeg
    let url = try await imageUploader.upload(image: imageData, imageType: imgType, uploadType: .feed)
    
    return try await challengeRepository.uploadChallengeFeedProof(id: challengeId, imageUrl: url)
  }
}
