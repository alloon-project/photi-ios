//
//  FindIdRepository.swift
//  Domain
//
//  Created by 임우섭 on 12/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper

public protocol FindIdRepository {
  init(dataMapper: FindIdDataMapper)
  
  func findId(userEmail: String) -> Single<Void>
}
