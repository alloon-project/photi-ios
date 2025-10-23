//
//  SignUpUseCase.swift
//  UseCase
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public protocol SignUpUseCase {
  func configureEmail(_ email: String)
  func configureUsername(_ username: String)

  func requestVerificationCode(email: String) async throws
  func verifyCode(email: String, code: String) async throws
  func verifyUserName(_ useName: String) async throws
  func remainingRejoinDays(email: String) async throws -> Int
  func register(password: String) async throws -> String
}
