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
  case popularHashTags
  case challengeDetail(id: Int)
  case myChallenges(page: Int, size: Int)
  case recentChallenges(page: Int, size: Int)
  case challengesByHashTag(_ hashTag: String, page: Int, size: Int)
  case searchChallengesByName(_ name: String, page: Int, size: Int)
  case searchChallengesByHashtag(_ hashtag: String, page: Int, size: Int)
  case fetchInviitationCode(id: Int)
  case verifyInvitationCode(id: Int, _ code: String)
  case joinChallenge(id: Int, goal: String)
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
      case .popularChallenges: return "challenges/popular"
      case .popularHashTags: return "challenges/hashtags"
      case .recentChallenges: return "challenges"
      case .challengesByHashTag: return "challenges/by-hashtags"
      case .searchChallengesByName: return "challenges/search/name"
      case .searchChallengesByHashtag: return "challenges/search/hashtag"
      case let .challengeDetail(id), let .leaveChallenge(id): return "challenges/\(id)"
      case .myChallenges: return "users/my-challenges"
      case let .joinChallenge(id, _): return "challenges/\(id)/join"
      case let .updateChallengeGoal(_, challengeId): return "challenges/\(challengeId)/challenge-members/goal"
      case let .fetchInviitationCode(id): return "challenges/\(id)/invitation-code"
      case let .verifyInvitationCode(id, _): return "challenges/\(id)/invitation-code-match"
      case let .uploadChallengeProof(id, _, _): return "challenges/\(id)/feeds"
      case let .isProve(challengeId): return "users/challenges/\(challengeId)/prove"
      case let .challengeDescription(id): return "challenges/\(id)/info"
      case let .challengeMember(challengeId): return "challenges/\(challengeId)/challenge-members"
      case .challengeCount: return "users/challenges"
      case let .challengeProveMemberCount(challengeId): return "challenges/\(challengeId)/feed-members"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .popularChallenges, .popularHashTags: return .get
      case .challengeDetail, .challengesByHashTag, .recentChallenges: return .get
      case .myChallenges, .fetchInviitationCode, .verifyInvitationCode: return .get
      case .searchChallengesByName, .searchChallengesByHashtag: return .get
      case .joinChallenge, .uploadChallengeProof: return .post
      case .isProve, .challengeCount, .challengeProveMemberCount: return .get
      case .updateChallengeGoal: return .patch
      case .challengeDescription, .challengeMember: return .get
      case .leaveChallenge: return .delete
    }
  }
  
  public var task: TaskType {
    switch self {
      case .popularChallenges, .challengeCount, .challengeDetail,
          .popularHashTags, .challengeProveMemberCount, .fetchInviitationCode:
        return .requestPlain
        
      case .isProve, .challengeDescription, .challengeMember, .leaveChallenge:
        return .requestPlain

      case let .myChallenges(page, size), let .recentChallenges(page, size):
        let parameters = ["page": page, "size": size]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .challengesByHashTag(hashTag, page, size), let .searchChallengesByHashtag(hashTag, page, size):
        let parameters = ["hashtag": hashTag, "page": "\(page)", "size": "\(size)"]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

      case let .searchChallengesByName(name, page, size):
        let parameters = ["challengeName": name, "page": "\(page)", "size": "\(size)"]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

      case let .joinChallenge(_, goal):
        let parameters = ["goal": goal]
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

      case let .updateChallengeGoal(goal, _):
        let parameters = ["goal": goal]
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
      
      case let .verifyInvitationCode(_, code):
        let parameters = ["invitationCode": code]
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
                
      case let .uploadChallengeProof(_, image, imageType):
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
      case .popularChallenges:
        let data = PopularChallengeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .challengeDetail:
        let data = ChallengeDetailResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .myChallenges:
        let data = MyChallengeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .joinChallenge, .uploadChallengeProof, .updateChallengeGoal, .leaveChallenge:
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
        
      case .verifyInvitationCode:
        let data = VerifyInvitationCodeResponseDTO.stubData
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
        
      case .popularHashTags:
        let data = """
          {
            "code": "200 OK",
            "message": "성공",
            "data": [
              { "hashtag": "러닝" }, { "hashtag": "코딩" }
            ]          
          }
        """
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .challengesByHashTag, .recentChallenges:
        let data = SearchChallengeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .searchChallengesByName:
        let data = SearchChallengeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
        
      case .searchChallengesByHashtag:
        let data = SearchChallengeByHashtagResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
      case .fetchInviitationCode(id: let id):
        let data = """
          {
            "code": "200 OK",
            "message": "성공",
            "data": {
              "name": "신나게 하는 러닝 챌린지",
              "invitationCode": "478DS"
            }
          }
          """
        let jsonData = data.data(using: .utf8)
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
    }
  }
}
