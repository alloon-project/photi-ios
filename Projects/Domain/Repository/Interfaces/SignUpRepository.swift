//
//  SignUpRepository.swift
//  Repository
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public protocol SignUpRepository {
  func requestVerificationCode(email: String) async throws
  func verifyCode(email: String, code: String) async throws
  func verifyUseName(_ userName: String) async throws
  func fetchWithdrawalDate(email: String) async throws -> Date
  func register(
    email: String,
    username: String,
    password: String
  ) async throws -> String
}
