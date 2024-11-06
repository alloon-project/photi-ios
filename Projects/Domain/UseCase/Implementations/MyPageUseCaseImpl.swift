//
//  MyPageUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Entity
import UseCase
import Repository

public struct MyPageUseCaseImpl: MyPageUseCase {
  private let repository: MyPageRepository
  
  public init(repository: MyPageRepository) {
    self.repository = repository
  }
  
  public func userChallengeHistory() -> Single<UserChallengeHistory> {
    return repository.userChallengeHistory()
  }
}
