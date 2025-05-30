//
//  PaginationResponseDTO.swift
//  DTO
//
//  Created by jung on 5/29/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct PaginationResponseDTO<T: Decodable>: Decodable {
  public let content: [T]
  public let page: Int
  public let size: Int
  public let first: Bool
  public let last: Bool
}
