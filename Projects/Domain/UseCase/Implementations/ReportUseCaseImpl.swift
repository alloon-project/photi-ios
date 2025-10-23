//
//  ReportUseCaseImpl.swift
//  Domain
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UseCase
import Repository

public struct ReportUseCaseImpl: ReportUseCase {
  private let repository: ReportRepository
  
  public init(repository: ReportRepository) {
    self.repository = repository
  }
  
  public func report(
    category: String,
    reason: String,
    content: String,
    targetId: Int
  ) async throws -> Void {
    do {
      try await repository.report(
        category: category,
        reason: reason,
        content: content,
        targetId: targetId
      )
    } catch {
      throw error
    }
  }
}
