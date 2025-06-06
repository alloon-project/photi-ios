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
  case userInformation
  case uploadProfileImage(_ data: Data, imageType: String)
  case withdrawUser(password: String)
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
      case .userInformation: return "api/users"
      case .uploadProfileImage: return "api/users/image"
      case .withdrawUser: return "api/users"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .uploadProfileImage: return .post
      case .withdrawUser: return .patch
      default: return .get
    }
  }
  
  public var task: TaskType {
    switch self {
      case .userChallegeHistory, .verifiedChallengeDates, .userInformation:
        return .requestPlain
        
      case let .feedHistory(page, size), let .endedChallenges(page, size):
        let parameters = ["page": page, "size": size]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .feedsByDate(date):
        let parameters = ["date": date]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .withdrawUser(password):
        let parameters = ["password": password]
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        
      case let .uploadProfileImage(image, imageType):
        let multiPartBody = MultipartFormDataBodyPart(
          .data(["imageFile": image]),
          fileExtension: imageType,
          mimeType: "image/\(imageType)"
        )
        
        return .uploadMultipartFormData(multipart: .init(bodyParts: [multiPartBody]))
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
        
      case .userInformation, .uploadProfileImage:
        let data = UserProfileResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .withdrawUser:
        let data = """
          {
            "code": "200 OK",
            "message": "성공",
            "data": {
              "successMessage": "string"
            }
          }
        """
        let jsonData = data.data(using: .utf8)
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
    }
  }
}
