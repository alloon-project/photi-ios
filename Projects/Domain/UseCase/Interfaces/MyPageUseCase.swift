//
//  MyPageUseCase.swift
//  Domain
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Entity
import Repository

public protocol MyPageUseCase {
  init(repository: MyPageRepository)
  
  func userChallengeHistory() -> Single<UserChallengeHistory>
}
