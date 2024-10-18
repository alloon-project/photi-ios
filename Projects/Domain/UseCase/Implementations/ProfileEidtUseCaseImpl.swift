//
//  ProfileEditUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Entity
import UseCase
import Repository

public struct ProfileEditUseCaseImpl: ProfileEditUseCase {
  private let repository: ProfileEditRepository
  
  public init(repository: ProfileEditRepository) {
    self.repository = repository
  }
  
  public func userInfo() -> Single<UserProfile> {
    return repository.userInfo()
  }
}
