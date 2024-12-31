//
//  InquiryRepositoryImpl.swift
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

public struct InquiryRepositoryImpl: InquiryRepository {
  private let dataMapper: InquiryDataMapper
  
  public init(dataMapper: InquiryDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func inquiry(
    type: String,
    content: String
  ) -> Single<Void> {
    let requestDTO = dataMapper.mapToInquiryRequestDTO(type: type, content: content)
    
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(InquiryAPI.inquiry(dto: requestDTO)).value
          
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
