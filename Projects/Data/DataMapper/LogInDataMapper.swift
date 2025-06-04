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
  func mapToFindPasswordRequestDTO(userEmail: String, userName: String) -> FindPasswordRequestDTO
}

public struct LogInDataMapperImpl: LogInDataMapper {
  public init() { }
  
  public func mapToLogInRequestDTO(userName: String, password: String) -> LogInRequestDTO {
    return LogInRequestDTO(username: userName, password: password)
  }
  
  public func mapToFindPasswordRequestDTO(userEmail: String, userName: String) -> FindPasswordRequestDTO {
    return .init(email: userEmail, username: userName)
  }
}
