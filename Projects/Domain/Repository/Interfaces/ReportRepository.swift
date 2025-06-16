//
//  ReportRepository.swift
//  Domain
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift

public protocol ReportRepository {
  func report(
    category: String,
    reason: String,
    content: String,
    targetId: Int
  ) -> Single<Void>
}
