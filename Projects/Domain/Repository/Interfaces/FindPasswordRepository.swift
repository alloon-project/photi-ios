//
//  FindPasswordRepository.swift
//  Domain
//
//  Created by wooseob on 11/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper

public protocol FindPasswordRepository {
  init(dataMapper: FindPasswordDataMapper)
  
  func findPassword(userEmail: String, userName: String) -> Single<Void>
}
