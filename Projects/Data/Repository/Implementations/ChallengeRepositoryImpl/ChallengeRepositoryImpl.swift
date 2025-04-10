//
//  ChallengeRepositoryImpl.swift
//  DTO
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import DataMapper
import DTO
import Entity
import PhotiNetwork
import Repository

public struct ChallengeRepositoryImpl: ChallengeRepository {
  private let dataMapper: ChallengeDataMapper
  
  public init(dataMapper: ChallengeDataMapper) {
    self.dataMapper = dataMapper
  }
}

// MARK: - Fetch Methods
public extension ChallengeRepositoryImpl {
  func fetchPopularChallenges() -> Single<[ChallengeDetail]> {
    return requestUnAuthorizableAPI(
      api: ChallengeAPI.popularChallenges,
      responseType: [PopularChallengeResponseDTO].self,
      behavior: .never
    )
    .map { $0.map { dataMapper.mapToChallengeDetail(dto: $0) } }
  }
  
  func fetchEndedChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.endedChallenges(page: page, size: size),
      responseType: EndedChallengeResponseDTO.self
    )
    .map { dataMapper.mapToChallengeSummaryFromEnded(dto: $0) }
  }
  
  func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail> {
    return requestUnAuthorizableAPI(
      api: ChallengeAPI.challengeDetail(id: id),
      responseType: ChallengeDetailResponseDTO.self,
      behavior: .never
    )
    .map { dataMapper.mapToChallengeDetail(dto: $0, id: id) }
  }
  
  func isProve(challengeId: Int) async throws -> Bool {
    let api = ChallengeAPI.isProve(challengeId: challengeId)
    let result = try await requestAuthorizableAPI(
      api: api,
      responseType: ChallengeProveResponseDTO.self,
      behavior: .immediate
    ).value
    
    return result.isProve
  }
  
  func challengeCount() async throws -> Int {
    let result = try await requestAuthorizableAPI(
        api: ChallengeAPI.challengeCount,
        responseType: ChallengeCountResponseDTO.self,
        behavior: .never
      ).value
      
    return result.challengeCnt
  }
    
  func fetchMyChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.myChallenges(page: page, size: size),
      responseType: MyChallengesResponseDTO.self,
      behavior: .never
    )
    .map { dataMapper.mapToChallengeSummaryFromMyChallenge(dto: $0) }
  }
  
  func fetchChallengeDescription(challengeId: Int) -> Single<ChallengeDescription> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.challengeDescription(id: challengeId),
      responseType: ChallengeDescriptionResponseDTO.self,
      behavior: .never
    )
    .map { dataMapper.mapToChallengeDescription(dto: $0, id: challengeId) }
  }
  
  func fetchChallengeMembers(challengeId: Int) -> Single<[ChallengeMember]> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.challengeMember(challengeId: challengeId),
      responseType: [ChallengeMemberResponseDTO].self,
      behavior: .immediate
    )
    .map { dataMapper.mapToChallengeMembers(dto: $0) }
  }
}

// MARK: - Upload Methods
public extension ChallengeRepositoryImpl {
  func joinPrivateChallnege(id: Int, code: String) -> Single<Void> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.joinPrivateChallenge(id: id, code: code),
      responseType: SuccessResponseDTO.self,
      behavior: .immediate
    )
    .map { _ in () }
  }
  
  func joinPublicChallenge(id: Int) -> Single<Void> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.joinChallenge(id: id),
      responseType: SuccessResponseDTO.self,
      behavior: .immediate
    )
    .map { _ in () }
  }
  
  func updateChallengeGoal(_ goal: String, challengeId: Int) -> Single<Void> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.updateChallengeGoal(goal, challengeId: challengeId),
      responseType: SuccessResponseDTO.self,
      behavior: .delayed(seconds: 3)
    )
    .map { _ in }
  }
  
  func uploadChallengeFeedProof(id: Int, image: Data, imageType: String) async throws {
    let api = ChallengeAPI.uploadChallengeProof(id: id, image: image, imageType: imageType)
    
    let single = requestAuthorizableAPI(
      api: api,
      responseType: SuccessResponseDTO.self,
      behavior: .never
    )
    
    try await executeSingle(single)
  }
}

// MARK: - Delete Methods
public extension ChallengeRepositoryImpl {
  func leaveChallenge(id: Int) -> Single<Void> {
    return requestAuthorizableAPI(
      api: .leaveChallenge(challengeId: id),
      responseType: SuccessResponseDTO.self,
      behavior: .immediate
    )
    .map { _ in }
  }
}

// MARK: - Private Methods
private extension ChallengeRepositoryImpl {
  func requestAuthorizableAPI<T: Decodable>(
    api: ChallengeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) -> Single<T> {
    return Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeAPI>(
            stubBehavior: behavior,
            session: .init(interceptor: AuthenticationInterceptor())
          )
          
          let result = try await provider.request(api, type: responseType.self).value
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 400 {
            single(.failure(map400ToAPIError(result.code, result.message)))
          } else if result.statusCode == 401 || result.statusCode == 403 {
            single(.failure(APIError.authenticationFailed))
          } else if result.statusCode == 404 {
            single(.failure(map404ToAPIError(result.code, result.message)))
          } else if result.statusCode == 409 {
            single(.failure(map409ToAPIError(result.code, result.message)))
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
    api: ChallengeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) -> Single<T> {
    Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeAPI>(stubBehavior: behavior)
          let result = try await provider
            .request(api, type: responseType.self).value
          
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 400 {
            single(.failure(map400ToAPIError(result.code, result.message)))
          } else if result.statusCode == 404 {
            single(.failure(map404ToAPIError(result.code, result.message)))
          } else if result.statusCode == 409 {
            single(.failure(map409ToAPIError(result.code, result.message)))
          } else if result.statusCode == 413 {
            single(.failure(APIError.challengeFailed(reason: .fileTooLarge)))
          } else if result.statusCode == 415 {
            single(.failure(APIError.challengeFailed(reason: .invalidFileFormat)))
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
  
  func map400ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "CHALLENGE_INVITATION_CODE_INVALID" {
      return APIError.challengeFailed(reason: .invalidInvitationCode)
    } else if code == "CHALLENGE_LIMIT_EXCEED" {
      return APIError.challengeFailed(reason: .challengeLimitExceed)
    } else {
      return APIError.clientError(code: code, message: message)
    }
  }
  
  func map404ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "USER_NOT_FOUND" {
      return APIError.challengeFailed(reason: .userNotFound)
    } else if code == "CHALLENGE_NOT_FOUND" {
      return APIError.challengeFailed(reason: .challengeNotFound)
    } else if code == "CHALLENGE_MEMBER_NOT_FOUND" {
      return APIError.challengeFailed(reason: .notChallengeMemeber)
    } else {
      return APIError.clientError(code: code, message: message)
    }
  }
  
  func map409ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "EXISTING_CHALLENGE_MEMBER" {
      return APIError.challengeFailed(reason: .alreadyJoinedChallenge)
    } else if code == "EXISTING_FEED" {
      return APIError.challengeFailed(reason: .alreadyUploadFeed)
    } else {
      return APIError.clientError(code: code, message: message)
    }
  }
  
  @discardableResult
  func executeSingle<T>(_ single: Single<T>) async throws -> T {
    return try await single.value
  }
}
