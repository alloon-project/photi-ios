//
//  ResignDataMapper.swift
//  Data
//
//  Created by 임우섭 on 2/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import DTO

public protocol ResignDataMapper {
  func mapToResignRequestDTO(userPassword: String) -> ResignRequestDTO
}

public struct ResignDataMapperImpl: ResignDataMapper {
  public init() {}
  
  public func mapToResignRequestDTO(userPassword: String) -> ResignRequestDTO {
    return ResignRequestDTO(password: userPassword)
  }
}
