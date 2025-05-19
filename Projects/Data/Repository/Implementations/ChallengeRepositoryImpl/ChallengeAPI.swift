//
//  ChallengeAPI.swift
//  DTO
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum ChallengeAPI {
  case popularChallenges
  case challengeDetail(id: Int)
  case endedChallenges(page: Int, size: Int)
  case myChallenges(page: Int, size: Int)
  case joinChallenge(id: Int)
  case joinPrivateChallenge(id: Int, code: String)
  case uploadChallengeProof(id: Int, image: Data, imageType: String)
  case isProve(challengeId: Int)
  case challengeCount
  case challengeProveMemberCount(challengeId: Int)
  case updateChallengeGoal(_ goal: String, challengeId: Int)
  case challengeDescription(id: Int)
  case challengeMember(challengeId: Int)
  case leaveChallenge(challengeId: Int)
}

extension ChallengeAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
      case .popularChallenges: return "api/challenges/popular"
      case let .challengeDetail(id), let .leaveChallenge(id): return "api/challenges/\(id)"
      case .endedChallenges: return "api/users/ended-challenges"
      case .myChallenges: return "api/users/my-challenges"
      case let .joinChallenge(id): return "api/challenges/\(id)/join/public"
      case let .joinPrivateChallenge(id, _): return "api/challenges/\(id)/join/private"
      case let .uploadChallengeProof(id, _, _): return "api/challenges/\(id)/feeds"
      case let .isProve(challengeId): return "api/users/challenges/\(challengeId)/prove"
      case let .updateChallengeGoal(_, challengeId): return "api/challenges/\(challengeId)/challenge-members/goal"
      case let .challengeDescription(id): return "api/challenges/\(id)/info"
      case let .challengeMember(challengeId): return "api/challenges/\(challengeId)/challenge-members"
      case .challengeCount: return "api/users/challenges"
      case let .challengeProveMemberCount(challengeId): return "api/challenges/\(challengeId)/feed-members"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .popularChallenges: return .get
      case .challengeDetail: return .get
      case .endedChallenges, .myChallenges: return .get
      case .joinChallenge, .joinPrivateChallenge: return .post
      case .uploadChallengeProof: return .post
      case .isProve, .challengeCount, .challengeProveMemberCount: return .get
      case .updateChallengeGoal: return .patch
      case .challengeDescription: return .get
      case .challengeMember: return .get
      case .leaveChallenge: return .delete
    }
  }
  
  public var task: TaskType {
    switch self {
      case .popularChallenges, .challengeCount, .challengeDetail, .challengeProveMemberCount:
        return .requestPlain
        
      case let .endedChallenges(page, size), let .myChallenges(page, size):
        let parameters = ["page": page, "size": size]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case .joinChallenge:
        return .requestPlain

      case let .joinPrivateChallenge(_, code):
        let parameters = ["invitationCode": code]
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
                
      case let .uploadChallengeProof(_, image, imageType):
        let multiPartBody = MultipartFormDataBodyPart(
          .data(["imageFile": image]),
          fileExtension: imageType,
          mimeType: "image/\(imageType)"
        )
        
        return .uploadMultipartFormData(multipart: .init(bodyParts: [multiPartBody]))

      case .isProve:
        return .requestPlain
        
      case let .updateChallengeGoal(goal, _):
        let parameters = ["goal": goal]
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        
      case .challengeDescription, .challengeMember, .leaveChallenge:
        return .requestPlain
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .popularChallenges:
        let data = PopularChallengeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .challengeDetail:
        let data = ChallengeDetailResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .endedChallenges:
        let data = EndedChallengeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .myChallenges:
        let data = MyChallengesResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")

      case .joinChallenge, .joinPrivateChallenge, .uploadChallengeProof, .updateChallengeGoal, .leaveChallenge:
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
        
      case .isProve:
        let data = ChallengeProveResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
 
      case .challengeDescription:
        let data = ChallengeDescriptionResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .challengeMember:
        let data = ChallengeMemberResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .challengeCount:
        let data = ChallengeCountResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .challengeProveMemberCount:
        let data = ChallengeProveMemberCountResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
    }
  }
}
