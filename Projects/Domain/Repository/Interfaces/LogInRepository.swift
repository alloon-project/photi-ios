//
//  LogInRepository.swift
//  Repository
//
//  Created by jung on 8/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift

public protocol LogInRepository {
  func logIn(userName: String, password: String) -> Single<String>
  func requestUserInformation(email: String) -> Single<Void>
  func requestTemporaryPassword(email: String, userName: String) -> Single<Void>
  func updatePassword(from password: String, newPassword: String) -> Single<Void>
}
