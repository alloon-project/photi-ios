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

  public init(session: URLSession = URLSession(configuration: .default)) {
    self.session = session
  }
  
  public func request(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await self.session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.networkFailed(reason: .httpNoResponse)
    }
    
    return (data, httpResponse)
  }
}
