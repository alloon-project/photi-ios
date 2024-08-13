//
//  LogInDataMapper.swift
//  DTO
//
//  Created by jung on 8/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DTO

public protocol LogInDataMapper {
  func mapToLogInRequestDTO(userName: String, password: String) -> LogInRequestDTO
}

public struct LogInDataMapperImpl: LogInDataMapper {
  public init() {}
  
  public func mapToLogInRequestDTO(userName: String, password: String) -> LogInRequestDTO {
    return LogInRequestDTO(username: userName, password: password)
  }
}
