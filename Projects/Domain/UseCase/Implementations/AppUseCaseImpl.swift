//
//  AppUseCaseImpl.swift
//  UseCase
//
//  Created by jung on 6/1/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UseCase
import Repository

public final class AppUseCaseImpl: AppUseCase {
  private let repository: AuthRepository
  
  public init(repository: AuthRepository) {
    self.repository = repository
  }
  
  public func isLogIn() async -> Bool {
    return (try? await repository.isLogIn()) ?? false
  }
}
