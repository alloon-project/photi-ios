//
//  AppVersionRequestDTO.swift
//  DTO
//
//  Created by jung on 8/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

// swiftlint:disable identifier_name
public struct AppVersionRequestDTO: Encodable {
  public let os: String
  public let appVersion: String
  
  public init(os: String, appVersion: String) {
    self.os = os
    self.appVersion = appVersion
  }
}
// swiftlint:enable identifier_name
