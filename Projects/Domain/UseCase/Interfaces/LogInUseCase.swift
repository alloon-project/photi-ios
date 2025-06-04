//
//  LogInUseCase.swift
//  UseCase
//
//  Created by jung on 8/13/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift

public enum VerifyTemporaryPasswordResult {
  case success
  case mismatch
  case failure
}

public protocol LogInUseCase {
  func login(username: String, password: String) -> Single<Void>
  func sendUserInformation(to email: String) -> Single<Void>
  func sendTemporaryPassword(to email: String, userName: String) -> Single<Void>
  func verifyTemporaryPassword(_ password: String, name: String) async -> VerifyTemporaryPasswordResult
  func updatePassword(_ newPassword: String) async throws
}
