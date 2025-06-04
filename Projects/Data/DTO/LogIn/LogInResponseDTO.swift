//
//  LogInResponse.swift
//  DTO
//
//  Created by jung on 4/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct LogInResponseDTO: Decodable {
  public let userId: Int
  public let username: String
  public let imageUrl: String?
  public let temporaryPasswordYn: Bool
}
