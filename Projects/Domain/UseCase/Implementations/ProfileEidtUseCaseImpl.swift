//
//  ProfileEditUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Entity
import UseCase
import Repository

public final class ProfileEditUseCaseImpl: ProfileEditUseCase {
  private let repository: MyPageRepository
  
  public init(repository: MyPageRepository) {
    self.repository = repository
  }
}

public extension ProfileEditUseCaseImpl {
  func loadUserProfile() async throws -> UserProfile {
    return try await repository.fetchUserProfile()
  }
}
