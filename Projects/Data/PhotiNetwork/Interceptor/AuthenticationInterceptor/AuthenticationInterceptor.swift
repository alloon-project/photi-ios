//
//  AuthenticationInterceptor.swift
//  AlloonNetwork
//
//  Created by jung on 5/22/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public struct AuthenticationInterceptor: RequestInterceptorType {
  public init() { }
  
  public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
    guard let token = UserDefaults.standard.string(forKey: "Authorization") else {
      throw NetworkError.networkFailed(reason: .interceptorMapping)
    }
    var urlRequest = urlRequest
    urlRequest.headers.update(.authorization(acessToken: token))
    
    return urlRequest
  }
  
  public func retry(for response: HTTPURLResponse, data: Data) async -> RetryResult {
    guard let data = try? JSONDecoder().decode(MetaResponseDTO.self, from: data) else {
      let error = NetworkError.networkFailed(reason: .jsonDecodingFailed)
      return .doNotRetryWithError(error)
    }

    switch response.statusCode {
      case 401 where data.code == "TOKEN_UNAUTHENTICATED":
        guard let token = UserDefaults.standard.string(forKey: "Refresh-Token") else {
          let error = NetworkError.networkFailed(reason: .interceptorMapping)
          return .doNotRetryWithError(error)
        }
        do {
          try await requestRefreshToken(token)
          return .retry
        } catch {
          return .doNotRetryWithError(error)
        }
        
      default:
        return .doNotRetry
    }
  }
}

// MARK: - Private Extension
private extension AuthenticationInterceptor {
  func requestRefreshToken(_ token: String) async throws {
    let response = try await Provider(stubBehavior: .never)
      .request(RefreshTokenAPI.refresh(token))
    
    if let accessToken = response.headers["Authorization"] {
      UserDefaults.standard.setValue(accessToken, forKey: "Authorization")
    }
    
    if let refreshToken = response.headers["Refresh-Token"] {
      UserDefaults.standard.setValue(refreshToken, forKey: "Refresh-Token")
    }
  }
}
