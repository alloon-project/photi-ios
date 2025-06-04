//
//  ProfileEditUseCase.swift
//  Domain
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Entity

public protocol ProfileEditUseCase {
  func loadUserProfile() async throws -> UserProfile
}
