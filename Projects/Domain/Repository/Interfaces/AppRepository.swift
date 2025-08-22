//
//  AppRepository.swift
//  Repository
//
//  Created by jung on 8/14/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public protocol AppRepository {
  func fetchForceUpdateRequired(version: String) async throws -> Bool
}
