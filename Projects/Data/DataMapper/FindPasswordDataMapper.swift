//
//  FindPasswordDataMapper.swift
//  Data
//
//  Created by wooseob on 11/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DTO

public protocol FindPasswordDataMapper {
  func mapToFindPasswordRequestDTO(userEmail: String, userName: String) -> FindPasswordRequestDTO
}

public struct FindPasswordDataMapperImpl: FindPasswordDataMapper {
  public init() {}
  
  public func mapToFindPasswordRequestDTO(userEmail: String, userName: String) -> FindPasswordRequestDTO {
    return FindPasswordRequestDTO(userEmail: userEmail, userName: userName)
  }
}
