//
//  ProfileEditUseCase.swift
//  Domain
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import Entity

public protocol ProfileEditUseCase {
  func loadUserProfile() async throws -> UserProfile
  func updateProfileImage(_ image: UIImageWrapper) async throws -> URL?
  func withdraw(with password: String) async throws
  func changePassword(from password: String, to newPassword: String) async throws
}
