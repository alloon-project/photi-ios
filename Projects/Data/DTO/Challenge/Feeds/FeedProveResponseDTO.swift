//
//  FeedProveResponseDTO.swift
//  DTO
//
//  Created by jung on 12/26/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct FeedProveResponseDTO: Decodable {
  public let id: Int
  public let imageUrl: String?
  public let createdDateTime: String
  public let isLike: Bool
}
