//
//  ChangePasswordUseCaseImpl.swift
//  Domain
//
//  Created by wooseob on 12/5/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import UseCase
import Repository

public struct ChangePasswordUseCaseImpl: ChangePasswordUseCase {
  private let repository: ChangePasswordRepository
  
  public init(repository: ChangePasswordRepository) {
    self.repository = repository
  }
  
  public func changePassword(
    password: String,
    newPassword: String,
    newPasswordReEnter: String
  ) -> Single<Void> {
    repository.changePassword(
      password: password,
      newPassword: newPassword,
      newPasswordReEnter: newPasswordReEnter
    )
  }
}
