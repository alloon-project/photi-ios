//
//  ChallengeOrganizeAPI.swift
//  Data
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core
import DTO
import PhotiNetwork

public enum ChallengeOrganizeAPI {
  case sampleImages
  case organizeChallenge(dto: ChallengeOrganizeRequestDTO)
  case modifyChallenge(dto: ChallengeModifyRequestDTO, challengeId: Int)
}

extension ChallengeOrganizeAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
      case .sampleImages: return "api/challenges/example-images"
      case .organizeChallenge: return "api/challenges"
      case let .modifyChallenge(_, id): return "api/challenges/\(id)"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .sampleImages: return .get
      case .organizeChallenge: return .post
      case .modifyChallenge: return .patch
    }
  }
  
  public var task: TaskType {
    switch self {
      case .sampleImages:
        return .requestPlain
    case let .organizeChallenge(dto):
      let requestDataPart = MultipartFormDataBodyPart(
        .jsonString(key: "request", json: dto.jsonString)
      )

      let imageDataPart = MultipartFormDataBodyPart(
        .data([
          "imageFile": dto.image
        ]),
        fileExtension: dto.imageType,
        mimeType: "image/\(dto.imageType)"
      )
      
      let multipart = MultipartFormData(bodyParts: [requestDataPart, imageDataPart])
            
      return .uploadMultipartFormData(multipart: multipart)
    case let .modifyChallenge(dto, _):
      let requestDataPart = MultipartFormDataBodyPart(
        .jsonString(key: "request", json: dto.jsonString)
      )

      let imageDataPart = MultipartFormDataBodyPart(
        .data([
          "imageFile": dto.image
        ]),
        fileExtension: dto.imageType,
        mimeType: "image/\(dto.imageType)"
      )
      
      let multipart = MultipartFormData(bodyParts: [requestDataPart, imageDataPart])
      
      return .uploadMultipartFormData(multipart: multipart)
    }
  }
  
  public var sampleResponse: EndpointSampleResponse {
    switch self {
      case .sampleImages:
        let data = ChallengeSampleImageResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
        
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
      case .organizeChallenge:
        let data = ChallengeOrganizeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
      
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
      case .modifyChallenge:
        let data = ChallengeOrganizeResponseDTO.stubData
        let jsonData = data.data(using: .utf8)
      
        return .networkResponse(200, jsonData ?? Data(), "OK", "성공")
    }
  }
}
