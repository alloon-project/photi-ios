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
  
  public func configureChallengePayload(_ type: PayloadType, value: Any) async {
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
      self.endDate = value as? String
    case .rules:
      self.rules = value as? [String] ?? []
    case .hashtags:
      self.hashtags = value as? [String] ?? []
    case .image:
      if let imageData = value as? Data {
        self.image = value as? Data
      }
      if
        let imageString = value as? String,
        let url = URL(string: imageString) {
        Task {
          do {
            let image = try await KingfisherManager.shared.retrieveImage(with: url)
            guard let (data, type) = imageToData(image.image, maxMB: 8) else { return }
            self.image = data
            self.imageType = type
          } catch {
            print("이미지 변환 실패")
          }
        }
      }
    case .imageType:
      self.imageType = value as? String
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
