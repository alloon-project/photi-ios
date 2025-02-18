//
//  AuthRepositoryImpl.swift
//  DTO
//
//  Created by jung on 2/12/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import PhotiNetwork
import Repository

public struct AuthRepositoryImpl: AuthRepository {
  public init() { }
  
  public func isLogIn() async -> Bool {
    let provider = Provider<AuthAPI>(
      stubBehavior: .immediate,
      session: .init(interceptor: AuthenticationInterceptor())
    )
    
    do {
      let result = try await provider
        .request(AuthAPI.isLogIn).value
      
      return result.statusCode == 200
    } catch {
      return false
    }
  }
}
