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
  private let loginRepository: LogInRepository
  private let imageUploader: PresignedImageUploader
  private let myPageRepository: MyPageRepository
  private let oauthRepository: OAuthRepository

  public init(
    authRepository: AuthRepository,
    loginRepository: LogInRepository,
    imageUploader: PresignedImageUploader,
    myPageRepository: MyPageRepository,
    oauthRepository: OAuthRepository
  ) {
    self.authRepository = authRepository
    self.loginRepository = loginRepository
    self.imageUploader = imageUploader
    self.myPageRepository = myPageRepository
    self.oauthRepository = oauthRepository
  }
}

public extension ProfileEditUseCaseImpl {
  func loadUserProfile() async throws -> UserProfile {
    let profile = try await myPageRepository.fetchUserProfile()
    ServiceConfiguration.shared.setAuthProvider(profile.provider.rawValue)
    return profile
  }
  
  func updateProfileImage(_ imageData: Data, type: String) async throws -> URL? {
    let imgType = ImageType(rawValue: type) ?? .jpeg
    let url = try await imageUploader.upload(image: imageData, imageType: imgType, uploadType: .userProfile)
    
    return try await myPageRepository.uploadProfileImage(path: url)
  }
  
  func withdraw(with credential: WithdrawCredential) async throws {
    switch credential {
    case let .password(password):
      try await myPageRepository.deleteUserAccount(password: password)
    case let .oauth(provider):
      switch provider {
      case .kakao:
        try await oauthRepository.withdrawKakao()
      case .google:
        try await oauthRepository.withdrawGoogle()
      case .apple:
        try await oauthRepository.withdrawApple()
      case .normal:
        break
      }
    }
    authRepository.removeToken()
  }
  
  func changePassword(from password: String, to newPassword: String) async throws {
    try await myPageRepository.updatePassword(from: password, to: newPassword)
  }
  
  func sendTemporaryPassword(to email: String, userName: String) async throws {
    try await loginRepository.requestTemporaryPassword(email: email, userName: userName)
  }
}
