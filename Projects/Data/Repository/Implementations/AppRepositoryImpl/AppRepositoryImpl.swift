//
//  AppRepositoryImpl.swift
//  DTO
//
//  Created by jung on 8/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import DTO
import Entity
import PhotiNetwork
import Repository

public class AppRepositoryImpl: AppRepository {
  public init() { }
  
  public func fetchForceUpdateRequired(version: String) async throws -> Bool {
    let provider = Provider<AppAPI>(stubBehavior: .never)
    let dto = AppVersionRequestDTO(os: "ios", appVersion: version)
    do {
      let result = try await provider.request(.appVersion(dto: dto), type: AppVersionResponseDTO.self).value
      
      if let data = result.data {
        return data.forceUpdate
      } else {
       return false
      }
    } catch {
      throw APIError.serverError
    }
  }
}
