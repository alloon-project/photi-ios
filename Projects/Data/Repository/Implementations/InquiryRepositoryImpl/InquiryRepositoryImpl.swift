//
//  InquiryRepositoryImpl.swift
//  Data
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DataMapper
import Entity
import Repository
import PhotiNetwork

public struct InquiryRepositoryImpl: InquiryRepository {
  private let dataMapper: InquiryDataMapper
  
  public init(dataMapper: InquiryDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func inquiry(type: String, content: String) async throws {
    let requestDTO = dataMapper.mapToInquiryRequestDTO(type: type, content: content)
    
    let result = try await Provider(
      stubBehavior: .never,
      session: .init(interceptor: AuthenticationInterceptor())
    ).request(InquiryAPI.inquiry(dto: requestDTO))
    
    if result.statusCode == 201 {
      return
    } else if result.statusCode == 401 || result.statusCode == 403 {
      throw APIError.authenticationFailed
    } else if result.statusCode == 404 {
      throw APIError.userNotFound
    }
  }
}
