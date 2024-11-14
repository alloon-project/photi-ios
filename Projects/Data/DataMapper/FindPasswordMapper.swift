//
//  FindPasswordMapper.swift
//  Data
//
//  Created by wooseob on 11/13/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DTO

public protocol FindPasswordMapper {
  func mapToFindPasswordRequestDTO(userEmail: String, userName: String) -> FindPasswordRequestDTO
}

public struct FindPasswordMapperImpl: FindPasswordMapper {
  public init() {}
  
  public func mapToFindPasswordRequestDTO(userEmail: String, userName: String) -> FindPasswordRequestDTO {
    return FindPasswordRequestDTO(userEmail: userEmail, userName: userName)
  }
}
