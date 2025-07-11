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
  
  func fetchFeedHistory(page: Int, size: Int) async throws -> PaginationResultType<FeedSummary> {
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
  
  func fetchFeeds(byDate date: String) async throws -> [FeedSummary] {
    let result = try await requestAuthorizableAPI(
      api: MyPageAPI.feedsByDate(date),
      responseType: [FeedByDateResponseDTO].self
    ).value
    
    return dataMapper.mapToFeedSummaryFromFeedsByDate(dtos: result)
  }
  
  func fetchUserProfile() async throws -> UserProfile {
    let result = try await requestAuthorizableAPI(
      api: MyPageAPI.userInformation,
      responseType: UserProfileResponseDTO.self
    ).value
    
    return dataMapper.mapToUserProfile(dto: result)
  }
}

// MARK: - Update Methods
public extension MyPageRepositoyImpl {
  func uploadProfileImage(_ image: Data, imageType: String) async throws -> URL? {
    let result = try await requestAuthorizableAPI(
      api: MyPageAPI.uploadProfileImage(image, imageType: imageType),
      responseType: UserProfileResponseDTO.self
    ).value
    
    return dataMapper.mapToUserProfile(dto: result).imageUrl
  }
  
  func deleteUserAccount(password: String) async throws {
    let single = requestAuthorizableAPI(
      api: MyPageAPI.withdrawUser(password: password),
      responseType: SuccessResponseDTO.self
    )
    
    try await executeSingle(single)
  }
  
  func updatePassword(from password: String, to newPassword: String) async throws {
    let dto = dataMapper.mapToChangePasswordRequestDTO(password: password, newPassword: newPassword)
    
    let single = requestAuthorizableAPI(
      api: MyPageAPI.changePassword(dto: dto),
      responseType: SuccessResponseDTO.self
    )
    
    try await executeSingle(single)
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
          } else if result.statusCode == 400 {
              single(.failure(map400ToAPIError(result.code, result.message)))
          } else if result.statusCode == 401 {
            single(.failure(map401ToAPIError(result.code, result.message)))
          } else if result.statusCode == 403 {
            single(.failure(APIError.authenticationFailed))
          } else if result.statusCode == 404 {
            single(.failure(map404ToAPIError(result.code, result.message)))
          } else if result.statusCode == 413 {
            single(.failure(APIError.myPageFailed(reason: .fileTooLarge)))
          } else if result.statusCode == 415 {
            single(.failure(APIError.myPageFailed(reason: .invalidFileFormat)))
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
  
  func map400ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "PASSWORD_MATCH_INVALID" {
      return APIError.myPageFailed(reason: .loginUnAuthenticated)
    } else {
      return APIError.clientError(code: code, message: message)
    }
  }
  
  func map401ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "LOGIN_UNAUTHENTICATED" {
      return APIError.myPageFailed(reason: .loginUnAuthenticated)
    } else if code == "TOKEN_UNAUTHENTICATED" {
      return APIError.authenticationFailed
    } else {
      return APIError.clientError(code: code, message: message)
    }
  }
  
  func map404ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "USER_NOT_FOUND" {
      return APIError.myPageFailed(reason: .userNotFound)
    } else {
      return APIError.clientError(code: code, message: message)
    }
  }
  
  @discardableResult
  func executeSingle<T>(_ single: Single<T>) async throws -> T {
    return try await single.value
  }
}
