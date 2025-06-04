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
  
  public func sendUserInformation(to email: String) -> Single<Void> {
    repository.requestUserInformation(email: email)
  }
  
  public func sendTemporaryPassword(to email: String, userName: String) -> Single<Void> {
    repository.requestTemporaryPassword(email: email, userName: userName)
  }
}
