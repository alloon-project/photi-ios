//
//  MyPageRepositoyImpl.swift
//  Data
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
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
  func fetchMyPageSummary() async throws -> MyPageSummary {
    let dto = try await requestAuthorizableAPI(
      api: MyPageAPI.userChallegeHistory,
      responseType: UserChallengeHistoryResponseDTO.self
    )
    return dataMapper.mapToMyPageSummary(from: dto)
  }
  
  func fetchVerifiedChallengeDates() async throws -> [Date] {
    let dto = try await requestAuthorizableAPI(
      api: MyPageAPI.verifiedChallengeDates,
      responseType: VerifiedChallengeDatesResponseDTO.self
    )
    return dataMapper.mapToDate(from: dto)
  }
  
  func fetchFeedHistory(page: Int, size: Int) async throws -> PaginationResultType<FeedSummary> {
    let dto = try await requestAuthorizableAPI(
      api: MyPageAPI.feedHistory(page: page, size: size),
      responseType: PaginationResponseDTO<FeedHistoryResponseDTO>.self
    )
    
    let feeds = dataMapper.mapToFeedHistory(dtos: dto.content)
    return .init(contents: feeds, isLast: dto.last)
  }
  
  func fetchEndedChallenges(page: Int, size: Int) async throws -> PaginationResultType<ChallengeSummary> {
    let dto = try await requestAuthorizableAPI(
      api: MyPageAPI.endedChallenges(page: page, size: size),
      responseType: PaginationResponseDTO<EndedChallengeResponseDTO>.self
    )
    
    let challenges = dataMapper.mapToChallengeSummaryFromEnded(dto: dto.content)
    return .init(contents: challenges, isLast: dto.last)
  }
  
  func fetchFeeds(byDate date: String) async throws -> [FeedSummary] {
    let dto = try await requestAuthorizableAPI(
      api: MyPageAPI.feedsByDate(date),
      responseType: [FeedByDateResponseDTO].self
    )
    
    return dataMapper.mapToFeedSummaryFromFeedsByDate(dtos: dto)
  }
  
  func fetchUserProfile() async throws -> UserProfile {
    let dto = try await requestAuthorizableAPI(
      api: MyPageAPI.userInformation,
      responseType: UserProfileResponseDTO.self
    )
    
    return dataMapper.mapToUserProfile(dto: dto)
  }
}

// MARK: - Update Methods
public extension MyPageRepositoyImpl {
  func uploadProfileImage(path: String) async throws {
    do {
      try await requestAuthorizableAPI(
        api: .uploadProfileImage(url: path),
        responseType: SuccessResponseDTO.self
      )
    } catch {
      print(error)
      throw error
    }
  }
  
  func deleteUserAccount(password: String) async throws {
    try await requestAuthorizableAPI(
      api: MyPageAPI.withdrawUser(password: password),
      responseType: SuccessResponseDTO.self
    )
  }
  
  func updatePassword(from password: String, to newPassword: String) async throws {
    let dto = dataMapper.mapToChangePasswordRequestDTO(password: password, newPassword: newPassword)
    
    try await requestAuthorizableAPI(
      api: MyPageAPI.changePassword(dto: dto),
      responseType: SuccessResponseDTO.self
    )
  }
}

// MARK: - Private Methods
private extension MyPageRepositoyImpl {
  @discardableResult
  func requestAuthorizableAPI<T: Decodable>(
    api: MyPageAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) async throws -> T {
    do {
      let provider = Provider<MyPageAPI>(
        stubBehavior: behavior,
        session: .init(interceptor: AuthenticationInterceptor())
      )
      let result = try await provider.request(api, type: responseType.self)
      if (200..<300).contains(result.statusCode), let data = result.data {
        return data
      } else if result.statusCode == 400 {
        throw map400ToAPIError(result.code, result.message)
      } else if result.statusCode == 401 {
        throw map401ToAPIError(result.code, result.message)
      } else if result.statusCode == 403 {
        throw APIError.authenticationFailed
      } else if result.statusCode == 404 {
        throw map404ToAPIError(result.code, result.message)
      } else if result.statusCode == 413 {
        throw APIError.myPageFailed(reason: .fileTooLarge)
      } else if result.statusCode == 415 {
        throw APIError.myPageFailed(reason: .invalidFileFormat)
      } else {
        throw APIError.serverError          }
    } catch {
      if case NetworkError.networkFailed(reason: .interceptorMapping) = error {
        throw APIError.authenticationFailed
      } else {
        throw error
      }
    }
  }
}

// MARK: - Error Mapping
private extension MyPageRepositoyImpl {
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
}
