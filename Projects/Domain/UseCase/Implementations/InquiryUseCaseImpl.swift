//
//  InquiryUseCaseImpl.swift
//  Domain
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UseCase
import Repository

public struct InquiryUseCaseImpl: InquiryUseCase {
  private let repository: InquiryRepository
  
  public init(repository: InquiryRepository) {
    self.repository = repository
  }
  
  public func inquiry(type: String, content: String) async throws -> Void {
      try await repository.inquiry(type: type, content: content)
  }
}
