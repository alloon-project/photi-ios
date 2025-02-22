//
//  ResignUseCase.swift
//  Domain
//
//  Created by 임우섭 on 2/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Repository

public protocol ResignUseCase {
  init(repository: ResignRepository)
  
  func resign(password: String) -> Single<Void>
}
