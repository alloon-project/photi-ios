//
//  FindIdUseCase.swift
//  Domain
//
//  Created by 임우섭 on 12/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Repository

public protocol FindIdUseCase {
  init(repository: FindIdRepository)
  
  func findId(userEmail: String) -> Single<Void>
}
