//
//  MyPageRepository.swift
//  Domain
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import Entity

public protocol MyPageRepository {
  init (dataMapper: MyPageDataMapper)
  
  func userChallengeHistory() -> Single<UserChallengeHistory>
}
