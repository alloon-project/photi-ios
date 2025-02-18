//
//  ResignUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 2/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity
import UseCase
import Repository

public struct ResignUseCaseImpl: ResignUseCase {
  private let repository: ResignRepository
  
  public init(repository: ResignRepository) {
    self.repository = repository
  }
  
  public func resign(password: String) -> Single<Void> {
    return repository.resign(password: password)
  }
}
