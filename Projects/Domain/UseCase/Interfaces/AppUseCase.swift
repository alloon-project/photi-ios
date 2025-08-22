//
//  AppUseCase.swift
//  UseCase
//
//  Created by jung on 6/1/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public protocol AppUseCase {
  func isLogIn() async -> Bool
  func isAppForceUpdateRequired() async throws -> Bool
}
