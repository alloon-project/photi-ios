//
//  SignUpRepository.swift
//  Repository
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift

public protocol SignUpRepository {
  func requestVerificationCode(email: String) -> Single<Void>
  func verifyCode(email: String, code: String) -> Single<Void>
  func verifyUseName(_ userName: String) -> Single<Void>
  func register(
    email: String,
    username: String,
    password: String
  ) -> Single<String>
}
