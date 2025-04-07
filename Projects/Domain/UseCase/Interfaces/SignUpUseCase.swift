//
//  SignUpUseCase.swift
//  UseCase
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift

public protocol SignUpUseCase {
  func configureEmail(_ email: String)
  func configureUsername(_ username: String)

  func requestVerificationCode(email: String) -> Single<Void>
  func verifyCode(email: String, code: String) -> Single<Void>
  func verifyUserName(_ useName: String) -> Single<Void>
  func register(password: String) -> Single<String>
}
