//
//  LogInUseCase.swift
//  UseCase
//
//  Created by jung on 8/13/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Repository

public protocol LogInUseCase {
  init(repository: LogInRepository)
  
  func login(username: String, password: String) -> Single<Void>
}
