//
//  LogInUseCase.swift
//  UseCase
//
//  Created by jung on 8/13/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift

public protocol LogInUseCase {
  func login(username: String, password: String) -> Single<Void>
  func findId(userEmail: String) -> Single<Void>
  func findPassword(userEmail: String, userName: String) -> Single<Void>
}
