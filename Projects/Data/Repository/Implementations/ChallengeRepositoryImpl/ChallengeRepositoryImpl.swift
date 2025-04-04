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
      responseType: [PopularChallengeResponseDTO].self
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
      behavior: .immediate
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
    
  func fetchMyChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.myChallenges(page: page, size: size),
      responseType: MyChallengesResponseDTO.self,
      behavior: .immediate
    )
    .map { dataMapper.mapToChallengeSummaryFromMyChallenge(dto: $0) }
  }
  
  func fetchChallengeDescription(challengeId: Int) -> Single<ChallengeDescription> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.challengeDescription(id: challengeId),
      responseType: ChallengeDescriptionResponseDTO.self,
      behavior: .immediate
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
    let provider = Provider<ChallengeAPI>(
      stubBehavior: .immediate,
      session: .init(interceptor: AuthenticationInterceptor())
    )
    
    guard let result = try? await provider.request(api).value else {
      throw APIError.serverError
    }
    
    if result.statusCode == 401 || result.statusCode == 403 {
      throw APIError.authenticationFailed
    } else if result.statusCode == 404 {
      throw APIError.userNotFound
    } else if result.statusCode == 409 {
      throw APIError.challengeFailed(reason: .alreadyUploadFeed)
    }
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
    behavior: StubBehavior = .immediate
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
            single(.failure(APIError.challengeFailed(reason: .invalidInvitationCode)))
          } else if result.statusCode == 401 || result.statusCode == 403 {
            single(.failure(APIError.authenticationFailed))
          } else if result.statusCode == 404 {
            single(.failure(APIError.challengeFailed(reason: .challengeNotFound)))
          } else if result.statusCode == 409 {
            single(.failure(APIError.challengeFailed(reason: .alreadyJoinedChallenge)))
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
  
  func requestUnAuthorizableAPI<T: Decodable>(
    api: ChallengeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .immediate
  ) -> Single<T> {
    Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeAPI>(stubBehavior: behavior)
          let result = try await provider
            .request(api, type: responseType.self).value
          
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 404 {
            single(.failure(APIError.challengeFailed(reason: .challengeNotFound)))
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
