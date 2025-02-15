//
//  ReportRepository.swift
//  Domain
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper

public protocol ReportRepository {
  init(dataMapper: ReportDataMapper)
  
  func report(
    category: String,
    reason: String,
    content: String,
    targetId: Int
  ) -> Single<Void>
}
