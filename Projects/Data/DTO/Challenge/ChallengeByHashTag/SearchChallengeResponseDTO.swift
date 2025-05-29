//
//  SearchChallengeResponseDTO.swift
//  DTO
//
//  Created by jung on 5/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct SearchChallengeResponseDTO: Decodable {
  public let id: Int
  public let name: String
  public let imageUrl: String?
  public let endDate: String
  public let hashtags: [HashTagResponseDTO]
}
