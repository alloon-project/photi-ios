//
//  SignUpUseCase.swift
//  UseCase
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Repository

public protocol SignUpUseCase {
  init(repository: SignUpRepository)
  
  func requestVerificationCode(email: String) -> Single<Void>
  func verifyCode(email: String, code: String) -> Single<Void>
  func verifyUseName(_ useName: String) -> Single<Void>
}
