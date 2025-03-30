//
//  FeedRepositoryImpl.swift
//  Data
//
//  Created by 임우섭 on 2/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import DTO
import Entity
import PhotiNetwork
import Repository

public struct FeedHistoryRepositoryImpl: FeedHistoryRepository {
  private let dataMapper: FeedHistoryDataMapper
  
  public init(dataMapper: FeedHistoryDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func fetchFeedHistory(page: Int, size: Int) -> Single<[FeedHistory]> {
    return requestFeedHistory(
      api: FeedHistoryAPI.feedHistory(page: page, size: size),
      responseType: FeedHistoryResponseDTO.self,
      behavior: .immediate
    )
    .map { dataMapper.mapToFeedHistory(dto: $0) }
  }
}

// MARK: - Private Methods
private extension FeedHistoryRepositoryImpl {
  func requestFeedHistory<T: Decodable>(
    api: FeedHistoryAPI,
    responseType: T.Type,
    behavior: StubBehavior = .immediate
  ) -> Single<T> {
    return Single.create { single in
      Task {
        do {
          let provider = Provider<FeedHistoryAPI>(
            stubBehavior: behavior,
            session: .init(interceptor: AuthenticationInterceptor())
          )
          
          let result = try await provider
            .request(api, type: responseType.self).value
          
          if result.statusCode == 200, let data = result.data {
            single(.success(data))
          } else if result.statusCode == 401 {
            single(.failure(APIError.tokenUnauthenticated))
          } else if result.statusCode == 403 {
            single(.failure(APIError.tokenUnauthorized))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          single(.failure(error))
        }
      }
      return Disposables.create()
    }
  }
}
