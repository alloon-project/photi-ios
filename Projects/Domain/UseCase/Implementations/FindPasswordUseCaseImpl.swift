//
//  FindPasswordUseCaseImpl.swift
//  Domain
//
//  Created by wooseob on 11/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import UseCase
import Repository

public struct FindPasswordUseCaseImpl: FindPasswordUseCase {
  private let repository: FindPasswordRepository
  
  public init(repository: FindPasswordRepository) {
    self.repository = repository
  }
  
  public func findPassword(userEmail: String, userName: String) -> Single<Void> {
    repository.findPassword(userEmail: userEmail, userName: userName)
  }
}
