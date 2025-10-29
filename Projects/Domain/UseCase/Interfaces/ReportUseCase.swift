//
//  ReportUseCase.swift
//  Domain
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public protocol ReportUseCase {
  func report(
    category: String,
    reason: String,
    content: String,
    targetId: Int
  ) async throws -> Void
}
