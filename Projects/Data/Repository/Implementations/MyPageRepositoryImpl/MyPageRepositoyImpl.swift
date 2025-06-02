//
//  MyPageRepositoyImpl.swift
//  Data
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import DataMapper
import DTO
import Entity
import Repository
import PhotiNetwork

public struct MyPageRepositoyImpl: MyPageRepository {
  private let dataMapper: MyPageDataMapper
  
  public init(dataMapper: MyPageDataMapper) {
    self.dataMapper = dataMapper
  }
}

// MARK: - Fetch Methods
public extension MyPageRepositoyImpl {
  func fetchMyPageSummary() -> Single<MyPageSummary> {
    return requestAuthorizableAPI(
      api: MyPageAPI.userChallegeHistory,
      responseType: UserChallengeHistoryResponseDTO.self
    )
    .map { dataMapper.mapToMyPageSummary(from: $0) }
  }
  
  func fetchVerifiedChallengeDates() -> Single<[Date]> {
    return requestAuthorizableAPI(
      api: MyPageAPI.verifiedChallengeDates,
      responseType: VerifiedChallengeDatesResponseDTO.self
    )
    .map { dataMapper.mapToDate(from: $0) }
  }
  
  func fetchFeedHistory(page: Int, size: Int) async throws -> PaginationResultType<FeedHistory> {
    let result = try await requestAuthorizableAPI(
      api: MyPageAPI.feedHistory(page: page, size: size),
      responseType: PaginationResponseDTO<FeedHistoryResponseDTO>.self
    ).value
    
    let feeds = dataMapper.mapToFeedHistory(dtos: result.content)
    return .init(contents: feeds, isLast: result.last)
  }
  
  func fetchEndedChallenges(page: Int, size: Int) async throws -> PaginationResultType<ChallengeSummary> {
    let result = try await requestAuthorizableAPI(
      api: MyPageAPI.endedChallenges(page: page, size: size),
      responseType: PaginationResponseDTO<EndedChallengeResponseDTO>.self
    ).value
    
    let challenges = dataMapper.mapToChallengeSummaryFromEnded(dto: result.content)
    return .init(contents: challenges, isLast: result.last)
  }
}

// MARK: - Private Methods
private extension MyPageRepositoyImpl {
  func requestAuthorizableAPI<T: Decodable>(
    api: MyPageAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) -> Single<T> {
    return Single.create { single in
      Task {
        do {
          let provider = Provider<MyPageAPI>(
            stubBehavior: behavior,
            session: .init(interceptor: AuthenticationInterceptor())
          )
          
          let result = try await provider.request(api, type: responseType.self).value
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 401 || result.statusCode == 403 {
            single(.failure(APIError.authenticationFailed))
          } else if result.statusCode == 404 {
            single(.failure(map404ToAPIError(result.code, result.message)))
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
  
  func map404ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "USER_NOT_FOUND" {
      return APIError.challengeFailed(reason: .userNotFound)
    } else {
      return APIError.clientError(code: code, message: message)
    }
  }
}
