//
//  LogInRepository.swift
//  Repository
//
//  Created by jung on 8/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift

public protocol LogInRepository {
  func logIn(userName: String, password: String) -> Single<Void>
}
