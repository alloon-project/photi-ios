//
//  APIError.swift
//  Entity
//
//  Created by jung on 5/25/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

public enum APIError: Error {
  case authenticationFailed
  case clientError(code: String, message: String)
  case serverError
}
