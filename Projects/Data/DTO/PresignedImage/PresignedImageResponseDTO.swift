//
//  PresignedImageResponseDTO.swift
//  DTO
//
//  Created by jung on 12/10/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct PresignedImageResponseDTO: Decodable {
  public let presignedURL: String
  
  enum CodingKeys: String, CodingKey {
    case presignedURL = "preSignedUrl"
  }
}
