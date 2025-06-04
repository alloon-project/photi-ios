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

public final class LogInUseCaseImpl: LogInUseCase {
  private let repository: LogInRepository
  
  public init(repository: LogInRepository) {
    self.repository = repository
  }
  
  public func login(username: String, password: String) -> Single<Void> {
    repository.logIn(userName: username, password: password)
  }
  
  public func findId(userEmail: String) -> Single<Void> {
    repository.findId(userEmail: userEmail)
  }
  public func findPassword(userEmail: String, userName: String) -> Single<Void> {
    repository.findPassword(userEmail: userEmail, userName: userName)
  }
}
