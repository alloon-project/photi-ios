//
//  ProfileEditUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Entity
import UseCase
import Repository

public final class ProfileEditUseCaseImpl: ProfileEditUseCase {
  private let authRepository: AuthRepository
  private let loginRepository: LogInRepository
  private let imageUploader: PresignedImageUploader
  private let myPageRepository: MyPageRepository
  
  public init(
    authRepository: AuthRepository,
    loginRepository: LogInRepository,
    imageUploader: PresignedImageUploader,
    myPageRepository: MyPageRepository
  ) {
    self.authRepository = authRepository
    self.loginRepository = loginRepository
    self.imageUploader = imageUploader
    self.myPageRepository = myPageRepository
  }
}

public extension ProfileEditUseCaseImpl {
  func loadUserProfile() async throws -> UserProfile {
    return try await myPageRepository.fetchUserProfile()
  }
  
  func updateProfileImage(_ imageData: Data, type: String) async throws -> URL? {
    let imgType = ImageType(rawValue: type) ?? .jpeg
    let url = try await imageUploader.upload(image: imageData, imageType: imgType, uploadType: .userProfile)
    
    try await myPageRepository.uploadProfileImage(path: url)
    return URL(string: url)
  }
  
  func withdraw(with password: String) async throws {
    try await myPageRepository.deleteUserAccount(password: password)
    authRepository.removeToken()
  }
  
  func changePassword(from password: String, to newPassword: String) async throws {
    try await myPageRepository.updatePassword(from: password, to: newPassword)
  }
  
  func sendTemporaryPassword(to email: String, userName: String) async throws {
    try await loginRepository.requestTemporaryPassword(email: email, userName: userName)
  }
}
