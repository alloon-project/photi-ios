//
//  ChangePasswordUseCase.swift
//  Domain
//
//  Created by wooseob on 12/5/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Repository

public protocol ChangePasswordUseCase {
  init(repository: ChangePasswordRepository)
  
  func changePassword(
    password: String,
    newPassword: String,
    newPasswordReEnter: String
  ) -> Single<Void>
}
