//
//  AppUseCaseImpl.swift
//  UseCase
//
//  Created by jung on 6/1/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import UseCase
import Repository

public final class AppUseCaseImpl: AppUseCase {
  private let authRepository: AuthRepository
  private let appRepository: AppRepository
  
  public init(authRepository: AuthRepository, appRepository: AppRepository) {
    self.authRepository = authRepository
    self.appRepository = appRepository
  }
  
  public func isLogIn() async -> Bool {
    return (try? await authRepository.isLogIn()) ?? false
  }
  
  public func isAppForceUpdateRequired() async throws -> Bool {
    let appVersion = Bundle.appVersion
    
    return try await appRepository.fetchForceUpdateRequired(version: appVersion)
  }
}
