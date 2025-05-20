//
//  ChallengeOrganizeRepositoryImpl.swift
//  Data
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxSwift
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
  func fetchChallengeSampleImage() -> Single<[String]> {
    return requestUnAuthorizableAPI(
      api: ChallengeOrganizeAPI.sampleImages,
      responseType: ChallengeSampleImageResponseDTO.self
    )
    .map { dataMapper.mapToSampleImages(dto: $0) }
  }
}

// MARK: - Upload Methods
public extension ChallengeOrganizeRepositoryImpl {
  func challengeOrganize(payload: ChallengeOrganizePayload
  ) -> Single<Void> {
    let requestDTO = dataMapper.mapToOrganizedChallenge(payload: payload)
    
    return requestAuthorizableAPI(
      api: ChallengeOrganizeAPI.organizeChallenge(dto: requestDTO),
      responseType: ChallengeOrganizeResponseDTO.self
    )
    .map { _ in () }
  }
}

// MARK: - Private Method
private extension ChallengeOrganizeRepositoryImpl {
  func requestAuthorizableAPI<T: Decodable>(
    api: ChallengeOrganizeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) -> Single<T> {
    return Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeOrganizeAPI>(
            stubBehavior: behavior,
            session: .init(interceptor: AuthenticationInterceptor())
          )
          
          let result = try await provider.request(api, type: responseType.self).value
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          if case NetworkError.networkFailed(reason: .interceptorMapping) = error {
            single(.failure(APIError.authenticationFailed))
          } else {
            single(.failure(error))
          }
        }
      }
      return Disposables.create()
    }
  }
  
  func requestUnAuthorizableAPI<T: Decodable>(
    api: ChallengeOrganizeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) -> Single<T> {
    Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeOrganizeAPI>(stubBehavior: behavior)
          let result = try await provider
            .request(api, type: responseType.self).value
          
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 400 {
            single(.failure(APIError.organazieFailed(reason: .emptyFileInvalid)))
          } else if result.statusCode == 413 {
            single(.failure(APIError.organazieFailed(reason: .fileSizeExceed)))
          } else if result.statusCode == 415 {
            single(.failure(APIError.organazieFailed(reason: .imageTypeUnsurported)))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          single(.failure(error))
        }
      }
      return Disposables.create()
    }
  }
}
