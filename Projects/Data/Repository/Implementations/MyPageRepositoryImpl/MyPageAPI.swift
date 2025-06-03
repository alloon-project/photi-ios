//
//  MyPageAPI.swift
//  Data
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum MyPageAPI {
  case userChallegeHistory
  case verifiedChallengeDates
  case feedHistory(page: Int, size: Int)
  case endedChallenges(page: Int, size: Int)
  case feedsByDate(_ date: String)
}

extension MyPageAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
      case .userChallegeHistory: return "api/users/challenge-history"
      case .verifiedChallengeDates: return "api/users/feeds"
      case .feedHistory: return "api/users/feed-history"
      case .endedChallenges: return "api/users/ended-challenges"
      case .feedsByDate: return "api/users/feeds-by-date"
    }
  }
  
  public var method: HTTPMethod {
    return .get
  }
  
  public var task: TaskType {
    switch self {
      case .userChallegeHistory, .verifiedChallengeDates:
        return .requestPlain
        
      case let .feedHistory(page, size), let .endedChallenges(page, size):
        let parameters = ["page": page, "size": size]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .feedsByDate(date):
        let parameters = ["date": date]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .userChallegeHistory:
        let data = UserChallengeHistoryResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .verifiedChallengeDates:
        let data = VerifiedChallengeDatesResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .feedHistory:
        let data = FeedHistoryResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .endedChallenges:
        let data = EndedChallengeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .feedsByDate:
        let data = FeedByDateResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
    }
  }
}
