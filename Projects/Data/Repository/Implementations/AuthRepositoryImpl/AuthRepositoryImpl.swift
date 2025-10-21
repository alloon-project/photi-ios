//
//  AuthRepositoryImpl.swift
//  DTO
//
//  Created by jung on 2/12/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Entity
import PhotiNetwork
import Repository

public struct AuthRepositoryImpl: AuthRepository {
  private let accessTokenKey = "Authorization"
  private let refreshTokenKey = "Refresh-Token"
  
  public init() { }
  
  public func isLogIn() async throws -> Bool {
    let provider = Provider<AuthAPI>(
      stubBehavior: .never,
      session: .init(interceptor: AuthenticationInterceptor())
    )
    
    do {
      let result = try await provider
        .request(AuthAPI.isLogIn)
      return result.statusCode == 200
    } catch {
      if case let NetworkError.networkFailed(reason) = error, reason == .interceptorMapping {
        return false
      } else {
      throw APIError.serverError
      }
    }
  }
  
  public func accessToken() -> String? {
    return UserDefaults.standard.string(forKey: accessTokenKey)
  }
  
  public func storeAccessToken(_ token: String) {
    UserDefaults.standard.set(token, forKey: accessTokenKey)
  }
  
  public func removeToken() {
    UserDefaults.standard.removeObject(forKey: accessTokenKey)
    UserDefaults.standard.removeObject(forKey: refreshTokenKey)
  }
}
