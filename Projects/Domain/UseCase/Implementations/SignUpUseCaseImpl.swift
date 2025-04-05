//
//  SignUpUseCaseImpl.swift
//  UseCase
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import UseCase
import Repository

public struct SignUpUseCaseImpl: SignUpUseCase {
  private let repository: SignUpRepository
  
  public init(repository: SignUpRepository) {
    self.repository = repository
  }
  
  public func requestVerificationCode(email: String) -> Single<Void> {
    return repository.requestVerificationCode(email: email)
  }
  
  public func verifyCode(email: String, code: String) -> Single<Void> {
    return repository.verifyCode(
      email: email.trimmingCharacters(in: .whitespacesAndNewlines),
      code: code.trimmingCharacters(in: .whitespacesAndNewlines)
    )
  }
  
  public func verifyUseName(_ useName: String) -> Single<Void> {
    return repository.verifyUseName(useName)
  }
  
  public func register(
    email: String,
    verificationCode: String,
    usernmae: String,
    password: String,
    passwordReEnter: String
  ) -> Single<String> {
    return repository.register(
      email: email,
      username: usernmae,
      password: password.trimmingCharacters(in: .whitespacesAndNewlines)
    )
  }
}
