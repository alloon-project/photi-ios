//
//  ChallengeOrganizeRepositoryImpl.swift
//  Data
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import DataMapper
import DTO
import Entity
import PhotiNetwork
import Repository

public struct ChallengeOrganizeRepositoryImpl: ChallengeOrganizeRepository {
  private let dataMapper: ChallengeOrganizeDataMapper
  
  public init(dataMapper: ChallengeOrganizeDataMapper) {
    self.dataMapper = dataMapper
  }
}

// MARK: - Fetch Methods
public extension ChallengeOrganizeRepositoryImpl {
  func fetchChallengeSampleImage() async throws -> [String] {
    return try await requestUnAuthorizableAPI(
      api: ChallengeOrganizeAPI.sampleImages,
      responseType: ChallengeSampleImageResponseDTO.self
    )
    .list
  }
}

// MARK: - Upload & Update Methods
public extension ChallengeOrganizeRepositoryImpl {
  func challengeOrganize(payload: ChallengeOrganizePayload) async throws -> ChallengeDetail {
    guard let requestDTO = dataMapper.mapToOrganizedChallenge(payload: payload) else {
      throw APIError.organazieFailed(reason: .payloadIsNil)
    }
    
    let dto = try await requestAuthorizableAPI(
      api: ChallengeOrganizeAPI.organizeChallenge(dto: requestDTO),
      responseType: ChallengeOrganizeResponseDTO.self
    )
    
    return dataMapper.mapToChallengeDetail(dto: dto)
  }
  
  func challengeModify(payload: ChallengeModifyPayload, challengeId: Int) async throws {
    let requestDTO = dataMapper.mapToModifyChallenge(payload: payload)
    
    try await requestAuthorizableAPI(
      api: ChallengeOrganizeAPI.modifyChallenge(dto: requestDTO, challengeId: challengeId),
      responseType: SuccessResponseDTO.self
    )
  }
}

// MARK: - Private Method
private extension ChallengeOrganizeRepositoryImpl {
  @discardableResult
  func requestAuthorizableAPI<T: Decodable>(
    api: ChallengeOrganizeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) async throws -> T {
    do {
      let provider = Provider<ChallengeOrganizeAPI>(
        stubBehavior: behavior,
        session: .init(interceptor: AuthenticationInterceptor())
      )
      let result = try await provider.request(api, type: responseType.self)
      
      if (200..<300).contains(result.statusCode), let data = result.data {
        return data
      } else if result.statusCode == 400 {
        throw APIError.organazieFailed(reason: .emptyFileInvalid)
      } else if result.statusCode == 401 {
        throw APIError.authenticationFailed
      } else if result.statusCode == 404 {
        throw APIError.organazieFailed(reason: .notChallengeMemeber)
      } else {
        throw APIError.serverError
      }
    } catch {
      if case NetworkError.networkFailed(reason: .interceptorMapping) = error {
        throw APIError.authenticationFailed
      } else {
        throw error
      }
    }
  }
  
  @discardableResult
  func requestUnAuthorizableAPI<T: Decodable>(
    api: ChallengeOrganizeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) async throws -> T {
    let provider = Provider<ChallengeOrganizeAPI>(stubBehavior: behavior)
    let result = try await provider
      .request(api, type: responseType.self)
    
    if (200..<300).contains(result.statusCode), let data = result.data {
      return data
    } else if result.statusCode == 400 {
      throw APIError.organazieFailed(reason: .emptyFileInvalid)
    } else if result.statusCode == 413 {
      throw APIError.organazieFailed(reason: .fileSizeExceed)
    } else if result.statusCode == 415 {
      throw APIError.organazieFailed(reason: .imageTypeUnsurported)
    } else {
      throw APIError.serverError
    }
  }
}
