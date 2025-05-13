//
//  OrganizeUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import Entity
import UseCase
import Repository

public class OrganizeUseCaseImpl: OrganizeUseCase {
  private let repository: ChallengeOrganizeRepository
  
  private var name: String?
  private var isPublic: Bool?
  private var goal: String?
  private var proveTime: String?
  private var endDate: Date?
  private var rules: [String] = []
  private var hashtags: [String] = []
  private var image: Data?
  private var imageType: String?
  
  public var payload: ChallengeOrganizePayload? {
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
  
  public init(repository: ChallengeOrganizeRepository) {
    self.repository = repository
  }
  
  public func configureChallengePayload(_ type: PayloadType, value: Any) {
    switch type {
    case .name:
      self.name = value as? String
    case .isPublic:
      self.isPublic = value as? Bool
    case .goal:
      self.goal = value as? String
    case .proveTime:
      self.proveTime = value as? String
    case .endDate:
      self.endDate = value as? Date
    case .rules:
      self.rules = value as? [String] ?? []
    case .hashtags:
      self.hashtags = value as? [String] ?? []
    case .image:
      self.image = value as? Data
    case .imageType:
      self.imageType = value as? String
    }
  }
}

// MARK: - Fetch Methods
public extension OrganizeUseCaseImpl {
  func fetchChallengeSampleImages() -> Single<[String]> {
    return repository.fetchChallengeSampleImage()
  }
}

// MARK: - Upload Methods
public extension OrganizeUseCaseImpl {
  func organizeChallenge() -> Single<Void> {
    guard
      let payload else {
      return singleWithError(APIError.organazieFailed(reason: .payloadIsNil))
    }

    return repository.challengeOrganize(payload: payload)
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
}
