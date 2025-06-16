//
//  ProfileEditUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Core
import Entity
import UseCase
import Repository

public final class ProfileEditUseCaseImpl: ProfileEditUseCase {
  private let authRepository: AuthRepository
  private let myPageRepository: MyPageRepository
  
  public init(authRepository: AuthRepository, myPageRepository: MyPageRepository) {
    self.authRepository = authRepository
    self.myPageRepository = myPageRepository
  }
}

public extension ProfileEditUseCaseImpl {
  func loadUserProfile() async throws -> UserProfile {
    return try await myPageRepository.fetchUserProfile()
  }
  
  func updateProfileImage(_ image: UIImageWrapper) async throws -> URL? {
    guard let (data, type) = imageToData(image, maxMB: 8) else {
      throw APIError.myPageFailed(reason: .fileTooLarge)
    }
    
    return try await myPageRepository.uploadProfileImage(data, imageType: type)
  }
  
  func withdraw(with password: String) async throws {
    try await myPageRepository.deleteUserAccount(password: password)
    authRepository.removeToken()
  }
  
  func changePassword(from password: String, to newPassword: String) async throws {
    try await myPageRepository.updatePassword(from: password, to: newPassword)
  }
}

// MARK: - Private Methods
private extension ProfileEditUseCaseImpl {
  func imageToData(_ image: UIImageWrapper, maxMB: Int) -> (image: Data, type: String)? {
    let maxSizeBytes = maxMB * 1024 * 1024
    
    if let data = image.image.pngData(), data.count <= maxSizeBytes {
      return (data, "png")
    } else if let data = image.image.converToJPEG(maxSizeMB: 8) {
      return (data, "jpeg")
    }
    return nil
  }
}
