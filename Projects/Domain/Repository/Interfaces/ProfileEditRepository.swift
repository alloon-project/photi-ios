//
//  ProfileEditRepository.swift
//  Domain
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import Entity

public protocol ProfileEditRepository {
  init (dataMapper: ProfileEditDataMapper)
  
  func userInfo() -> Single<UserProfile>
}
