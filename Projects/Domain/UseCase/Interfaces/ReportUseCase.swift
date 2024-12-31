//
//  ReportUseCase.swift
//  Domain
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Repository

public protocol ReportUseCase {
  init(repository: ReportRepository)
  
  func report(
    category: String,
    reason: String,
    content: String,
    targetId: Int
  ) -> Single<Void>
}
