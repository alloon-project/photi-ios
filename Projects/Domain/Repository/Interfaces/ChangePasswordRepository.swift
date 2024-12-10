//
//  ChangePasswordRepository.swift
//  Domain
//
//  Created by wooseob on 12/5/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper

public protocol ChangePasswordRepository {
  init(dataMapper: ChangePasswordDataMapper)
  func changePassword(
    password: String,
    newPassword: String,
    newPasswordReEnter: String
  ) -> Single<Void>
}
