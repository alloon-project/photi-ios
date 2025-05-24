//
//  Session.swift
//  AlloonNetwork
//
//  Created by jung on 4/24/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public protocol Sessionable {
  func request(request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

public struct Session: Sessionable {
  private let session: URLSession
  public let interceptor: RequestInterceptorType?
  
  public init(
    session: URLSession = URLSession(configuration: .default),
    interceptor: RequestInterceptorType? = nil
  ) {
    self.session = session
    self.interceptor = interceptor
  }
  
  public func request(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await sendRequest(request: request)
    
    guard let interceptor else { return (data, response) }
    
    switch await interceptor.retry(for: response, data: data) {
      case .retry:
        return try await sendRequest(request: request)
        
      case .doNotRetry:
        return (data, response)
        
      case .doNotRetryWithError(let error):
        throw error
    }
  }
}

// MARK: - Private Methods
private extension Session {
  func sendRequest(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    var request = request
    
    if let interceptor = interceptor { request = try interceptor.adapt(request)  }
    
    let (data, response) = try await self.session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.networkFailed(reason: .httpNoResponse)
    }
    if let accessToken = httpResponse.headers["Authorization"] {
      UserDefaults.standard.setValue(accessToken, forKey: "Authorization")
    }
    if let refreshToken = httpResponse.headers["Refresh-Token"] {
      UserDefaults.standard.setValue(refreshToken, forKey: "Refresh-Token")
    }
    
    return (data, httpResponse)
  }
}
