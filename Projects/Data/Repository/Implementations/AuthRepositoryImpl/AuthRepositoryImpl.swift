//
//  AuthRepositoryImpl.swift
//  DTO
//
//  Created by jung on 2/12/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Entity
import PhotiNetwork
import Repository

public struct AuthRepositoryImpl: AuthRepository {
  public init() { }
  
  public func isLogIn() async throws -> Bool {
    let provider = Provider<AuthAPI>(
      stubBehavior: .never,
      session: .init(interceptor: AuthenticationInterceptor())
    )
    
    do {
      let result = try await provider
        .request(AuthAPI.isLogIn).value
      return result.statusCode == 200
    } catch {
      if case let NetworkError.networkFailed(reason) = error, reason == .interceptorMapping {
        return false
      } else {
      throw APIError.serverError
      }
    }
  }
}
