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
}