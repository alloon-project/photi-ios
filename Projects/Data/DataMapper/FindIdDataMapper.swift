//
//  FindIdDataMapper.swift
//  Data
//
//  Created by 임우섭 on 12/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DTO

public protocol FindIdDataMapper {
  func mapToFindIdRequestDTO(userEmail: String) -> FindIdRequestDTO
}

public struct FindIdDataMapperImpl: FindIdDataMapper {
  public init() {}
  
  public func mapToFindIdRequestDTO(userEmail: String) -> FindIdRequestDTO {
    return FindIdRequestDTO(userEmail: userEmail)
  }
}
