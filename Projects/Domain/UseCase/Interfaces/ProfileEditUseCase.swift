//
//  ProfileEditUseCase.swift
//  Domain
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Entity
import Repository

public protocol ProfileEditUseCase {
  init(repository: ProfileEditRepository)
  
  func userInfo() -> Single<ProfileEditInfo>
}
