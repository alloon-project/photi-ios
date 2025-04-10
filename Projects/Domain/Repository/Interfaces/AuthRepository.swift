//
//  AuthRepository.swift
//  Repository
//
//  Created by jung on 2/12/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public protocol AuthRepository {
  func isLogIn() async throws -> Bool
}
