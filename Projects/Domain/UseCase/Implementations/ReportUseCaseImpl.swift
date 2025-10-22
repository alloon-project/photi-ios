//
//  ReportUseCaseImpl.swift
//  Domain
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
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
  ) -> Single<Void> {
    asyncToSingle {
      try await repository.report(
        category: category,
        reason: reason,
        content: content,
        targetId: targetId
      )
    }
  }
}

// MARK: - Private Methods
private extension ReportUseCaseImpl {
  func asyncToSingle<T>(_ work: @escaping () async throws -> T) -> Single<T> {
    Single.create { single in
      let task = Task {
        do {
          let value = try await work()
          single(.success(value))
        } catch {
          single(.failure(error))
        }
      }
      return Disposables.create { task.cancel() }
    }
  }
}
