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
}

extension ChallengeOrganizeAPI: TargetType {
  public var baseURL: URL {
    return ServiceConfiguration.shared.baseUrl
  }
  
  public var path: String {
    switch self {
      case .sampleImages: return "api/challenges/example-images"
      case .organizeChallenge: return "api/challenges"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
      case .sampleImages: return .get
      case .organizeChallenge: return .post
    }
  }
  
  public var task: TaskType {
    switch self {
      case .sampleImages:
        return .requestPlain
      case let .organizeChallenge(dto):
      let multiPartBody = MultipartFormDataBodyPart(.parameters(dto.toParameters()))
      let multiPartDataBody = MultipartFormDataBodyPart(
        .data(["imageFile": dto.image]),
        fileExtension: dto.imageType,
        mimeType: "image/\(dto.imageType)"
      )
      
      let multipart = MultipartFormData(bodyParts: [multiPartBody, multiPartDataBody])
      
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
    }
  }
}
