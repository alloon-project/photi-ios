//
//  LogInUseCase.swift
//  UseCase
//
//  Created by jung on 8/13/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public enum VerifyTemporaryPasswordResult {
  case success
  case mismatch
  case failure
}

public protocol LogInUseCase {
  func login(username: String, password: String) async throws
  func sendUserInformation(to email: String) async throws
  func sendTemporaryPassword(to email: String, userName: String) async throws
  func verifyTemporaryPassword(_ password: String, name: String) async -> VerifyTemporaryPasswordResult
  func updatePassword(_ newPassword: String) async throws
}
