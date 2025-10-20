//
//  InquiryUseCaseImpl.swift
//  Domain
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import UseCase
import Repository

public struct InquiryUseCaseImpl: InquiryUseCase {
  private let repository: InquiryRepository
  
  public init(repository: InquiryRepository) {
    self.repository = repository
  }
  
  public func inquiry(type: String, content: String) -> Single<Void> {
    asyncToSingle {
      return try await repository.inquiry(type: type, content: content)
    }
  }
}

// MARK: - Private Methods
private extension InquiryUseCaseImpl {
  func asyncToSingle<T>(_ work: @escaping () async throws -> T) -> Single<T> {
    Single.create { single in
      let task = Task {
        do {
          single(.success(try await work()))
        } catch {
          single(.failure(error))
        }
      }
      return Disposables.create { task.cancel() }
    }
  }
}
