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
  case updateChallengeGoal(_ goal: String, challengeId: Int)
  case challengeDescription(id: Int)
  case challengeMember(challengeId: Int)
  case leaveChallenge(challengeId: Int)
}

extension ChallengeAPI: TargetType {
  public var baseURL: URL {
    //    return ServiceConfiguration.baseUrl
    return URL(string: "http://localhost:8080/api")!
  }
  
  public var path: String {
    switch self {
      case .popularChallenges: return "challenges/popular"
      case let .challengeDetail(id), let .leaveChallenge(id): return "challenges/\(id)"
      case .endedChallenges: return "users/ended-challenges"
      case .myChallenges: return "/users/my-challenges"
      case let .joinChallenge(id): return "challenges/\(id)/join/public"
      case let .joinPrivateChallenge(id, _): return "challenges/\(id)/join/private"
      case let .uploadChallengeProof(id, _, _): return "challenges/\(id)/feeds"
      case let .isProve(challengeId): return "/users/challenges/\(challengeId)/prove"
      case let .updateChallengeGoal(_, challengeId): return "/challenges/\(challengeId)/challenge-members/goal"
      case let .challengeDescription(id): return "challenges/\(id)/info"
      case let .challengeMember(challengeId): return "/challenges/\(challengeId)/challenge-members"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .popularChallenges: return .get
      case .challengeDetail: return .get
      case .endedChallenges, .myChallenges: return .get
      case .joinChallenge, .joinPrivateChallenge: return .post
      case .uploadChallengeProof: return .post
      case .isProve: return .get
      case .updateChallengeGoal: return .patch
      case .challengeDescription: return .get
      case .challengeMember: return .get
      case .leaveChallenge: return .delete
    }
  }
  
  public var task: TaskType {
    switch self {
      case .popularChallenges:
        return .requestPlain
        
      case let .challengeDetail(challengeId):
        let parameters = ["challengeId": challengeId]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .endedChallenges(page, size), let .myChallenges(page, size):
        let parameters = ["page": page, "size": size]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .joinChallenge(challengeId):
        let parameters = ["challengeId": "\(challengeId)"]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

      case let .joinPrivateChallenge(challengeId, code):
        let urlParameters = ["challengeId": challengeId]
        let bodyParameters = ["invitationCode": code]
        return .requestCompositeParameters(bodyParameters: bodyParameters, urlParameters: urlParameters)
                
      case let .uploadChallengeProof(challengeId, image, imageType):
        let parameters = ["challengeId": challengeId]

        let multiPartBody = MultipartFormDataBodyPart(
          .data(["imageFile": image]),
          fileExtension: imageType,
          mimeType: "image/\(imageType)"
        )
        
        return .uploadCompositeMultipart(
          multipart: .init(bodyParts: [multiPartBody]),
          urlParameters: parameters
        )

      case let .isProve(challengeId):
        let parameters = ["challengeId": challengeId]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .updateChallengeGoal(goal, challengeId):
        let urlParameters = ["challengeId": challengeId]
        let bodyParameters = ["goal": goal]
        return .requestCompositeParameters(bodyParameters: bodyParameters, urlParameters: urlParameters)
        
      case let .challengeDescription(challengeId):
        let parameters = ["challengeId": challengeId]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
      case let .challengeMember(challengeId), let .leaveChallenge(challengeId):
        let parameters = ["challengeId": challengeId]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
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
    }
  }
}
