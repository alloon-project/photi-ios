//
//  FindIdUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 12/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import UseCase
import Repository

public struct FindIdUseCaseImpl: FindIdUseCase {
  private let repository: FindIdRepository
  
  public init(repository: FindIdRepository) {
    self.repository = repository
  }
  
  public func findId(userEmail: String) -> Single<Void> {
    repository.findId(userEmail: userEmail)
  }
}
