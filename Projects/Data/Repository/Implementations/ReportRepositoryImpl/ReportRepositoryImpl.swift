//
//  ReportRepositoryImpl.swift
//  Data
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DataMapper
import Entity
import Repository
import PhotiNetwork

public struct ReportRepositoryImpl: ReportRepository {
  private let dataMapper: ReportDataMapper
  
  public init(dataMapper: ReportDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func report(
    category: String,
    reason: String,
    content: String,
    targetId: Int
  ) async throws {
    let requestDTO = dataMapper.mapToReportRequestDTO(
      category: category,
      reason: reason,
      content: content
    )
    
    let provider = Provider<ReportAPI>(
      stubBehavior: .never,
      session: .init(interceptor: AuthenticationInterceptor())
    )
    let result = try await provider.request(ReportAPI.report(dto: requestDTO, targetId: targetId))
    
    if result.statusCode == 201 {
      return
    } else if result.statusCode == 401 || result.statusCode == 403 {
      throw APIError.authenticationFailed
    } else if result.statusCode == 404 {
      throw APIError.userNotFound
    }
  }
}
