//
//  ReportRepositoryImpl.swift
//  Data
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
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
  ) -> Single<Void> {
    let requestDTO = dataMapper.mapToReportRequestDTO(
      category: category,
      reason: reason,
      content: content
    )
    
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(ReportAPI.report(dto: requestDTO, targetId: targetId)).value
          
          if result.statusCode == 201 {
            single(.success(()))
          } else if result.statusCode == 401 {
            single(.failure(APIError.tokenUnauthenticated))
          } else if result.statusCode == 403 {
            single(.failure(APIError.tokenUnauthorized))
          } else if result.statusCode == 404 {
            single(.failure(APIError.userNotFound))
          }
        } catch {
          single(.failure(error))
        }
      }
      
      return Disposables.create()
    }
  }
}
