//
//  LogInRepository.swift
//  Repository
//
//  Created by jung on 8/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public protocol LogInRepository {
  @discardableResult func logIn(userName: String, password: String) async throws -> String
  func requestUserInformation(email: String) async throws
  func requestTemporaryPassword(email: String, userName: String) async throws
  func updatePassword(from password: String, newPassword: String) async throws
}
