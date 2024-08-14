//
//  LogInUseCaseImpl.swift
//  UseCase
//
//  Created by jung on 8/13/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import UseCase
import Repository

public struct LogInUseCaseImpl: LogInUseCase {
  private let repository: LogInRepository
  
  public init(repository: LogInRepository) {
    self.repository = repository
  }
  
  public func login(username: String, password: String) -> Single<Void> {
    repository.logIn(userName: username, password: password)
  }
}
