//
//  LogInRepository.swift
//  Repository
//
//  Created by jung on 8/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper

public protocol LogInRepository {
  init(dataMapper: LogInDataMapper)
  
  func logIn(userName: String, password: String) -> Single<Void>
}
