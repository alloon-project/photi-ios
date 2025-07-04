//
//  OrganizeUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import Kingfisher
import Entity
import UseCase
import Repository

public class OrganizeUseCaseImpl: OrganizeUseCase {
  private let repository: ChallengeOrganizeRepository
  
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
  
  private var organizePayload: ChallengeOrganizePayload? {
    guard
      let name = self.name,
      let isPublic = self.isPublic,
      let goal = self.goal,
      let proveTime = self.proveTime,
      let endDate = self.endDate,
      let image = self.image,
      let imageType = self.imageType
    else { return nil }
    
    return ChallengeOrganizePayload(
      name: name,
      isPublic: isPublic,
      goal: goal,
      proveTime: proveTime,
      endDate: endDate,
      rules: rules,
      hashtags: hashtags,
      image: image,
      imageType: imageType
    )
  }
  
  private var modifyPayload: ChallengeModifyPayload? {
    guard
      let name = self.name,
      let goal = self.goal,
      let proveTime = self.proveTime,
      let endDate = self.endDate,
      let image = self.image,
      let imageType = self.imageType
    else { return nil }
    
    return ChallengeModifyPayload(
      name: name,
      goal: goal,
      proveTime: proveTime,
      endDate: endDate,
      rules: rules,
      hashtags: hashtags,
      image: image,
      imageType: imageType
    )
  }
  
  public init(repository: ChallengeOrganizeRepository) {
    self.repository = repository
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
      self.proveTime = value
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
  func fetchChallengeSampleImages() -> Single<[String]> {
    return repository.fetchChallengeSampleImage()
  }
}

// MARK: - Upload & Update Methods
public extension OrganizeUseCaseImpl {
  func organizeChallenge() -> Single<ChallengeDetail> {
    guard
      let organizePayload else {
      return .error(APIError.organazieFailed(reason: .payloadIsNil))
    }

    return repository.challengeOrganize(payload: organizePayload)
  }
  
  func modifyChallenge() -> Single<Void> {
    guard
      let modifyPayload,
      let challengeId
    else {
      return .error(APIError.organazieFailed(reason: .payloadIsNil))
    }

    return repository.challengeModify(payload: modifyPayload, challengeId: challengeId)
  }
}

// MARK: - Private Methods
private extension OrganizeUseCaseImpl {
  func singleWithError<T>(_ error: Error, type: T.Type = Void.self) -> Single<T> {
    return Single<T>.create { single in
      single(.failure(error))
      return Disposables.create()
    }
  }
  
  func imageToData(_ image: KFCrossPlatformImage, maxMB: Int) -> (image: Data, type: String)? {
    let maxSizeBytes = maxMB * 1024 * 1024
    
    if let data = image.pngData(), data.count <= maxSizeBytes {
      return (data, "png")
    } else if let data = image.converToJPEG(maxSizeMB: 8) {
      return (data, "jpeg")
    }
    return nil
  }
}
