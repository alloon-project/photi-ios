//
//  OrganizeUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Entity
import UseCase
import Repository

public class OrganizeUseCaseImpl: OrganizeUseCase {
  private let repository: ChallengeOrganizeRepository
  private let imageUploader: PresignedImageUploader
  
  private var challengeId: Int?
  private var name: String?
  private var isPublic: Bool?
  private var goal: String?
  private var proveTime: String?
  private var endDate: String?
  private var rules: [String] = []
  private var hashtags: [String] = []
  private var image: Data?
  private var imageType: String?
  
  public init(repository: ChallengeOrganizeRepository, imageUploader: PresignedImageUploader) {
    self.repository = repository
    self.imageUploader = imageUploader
  }
  
  public func configureChallengePayload(_ type: PayloadType) {
    switch type {
    case let .name(value):
      self.name = value
    case let .isPublic(value):
      self.isPublic = value
    case let .goal(value):
      self.goal = value
    case let .proveTime(value):
      self.proveTime = value.replacingOccurrences(of: " ", with: "")
    case let .endDate(value):
      self.endDate = value
    case let .rules(value):
      self.rules = value
    case let .hashtags(value):
      self.hashtags = value
    case let .image(value):
      self.image = value
    case let .imageType(value):
      self.imageType = value
    }
  }
  
  public func setChallengeId(id: Int) {
    self.challengeId = id
  }
}

// MARK: - Fetch Methods
public extension OrganizeUseCaseImpl {
  func fetchChallengeSampleImages() async throws -> [String] {
    return try await repository.fetchChallengeSampleImage()
  }
}

// MARK: - Upload & Update Methods
public extension OrganizeUseCaseImpl {
  func organizeChallenge() async throws -> ChallengeDetail {
    guard let image, let imageType else {
      throw APIError.organazieFailed(reason: .payloadIsNil)
    }
    let imgType = ImageType(rawValue: imageType) ?? .jpeg
    let url = try await imageUploader.upload(image: image, imageType: imgType, uploadType: .challengeProfile)
    
    guard let organizePayload = organizePayload(with: url) else {
      throw APIError.organazieFailed(reason: .payloadIsNil)
    }
    
    return try await repository.challengeOrganize(payload: organizePayload)
  }
  
  func modifyChallenge(id: Int, payload: ChallengeModifyPayload, imageChange: ImageChange) async throws {
    let finalPayload: ChallengeModifyPayload
    
    switch imageChange {
    case .keep:
      finalPayload = payload
    case let .replace(data, type):
      let imgType = ImageType(rawValue: type) ?? .jpeg
      let url = try await imageUploader.upload(
        image: data,
        imageType: imgType,
        uploadType: .challengeProfile
      )
      finalPayload = modifyPayloadWithImageURL(payload, imageURL: url)
    }
    
    try await repository.challengeModify(payload: finalPayload, challengeId: id)
  }
}

// MARK: - Private Methods
private extension OrganizeUseCaseImpl {
  func modifyPayloadWithImageURL(_ payload: ChallengeModifyPayload, imageURL: String) -> ChallengeModifyPayload {
    return ChallengeModifyPayload(
      name: payload.name,
      goal: payload.goal,
      imageURL: imageURL,
      proveTime: payload.proveTime,
      endDate: payload.endDate,
      rules: payload.rules,
      hashtags: payload.hashtags
    )
  }
  
  func organizePayload(with imageURL: String) -> ChallengeOrganizePayload? {
    guard
      let name = self.name,
      let isPublic = self.isPublic,
      let goal = self.goal,
      let proveTime = self.proveTime,
      let endDate = self.endDate
    else { return nil }
    
    return ChallengeOrganizePayload(
      name: name,
      isPublic: isPublic,
      goal: goal,
      proveTime: proveTime,
      endDate: endDate,
      imageURL: imageURL,
      rules: rules,
      hashtags: hashtags
    )
  }
}
