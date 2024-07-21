//
//  ParameterEncoding.swift
//  AlloonNetwork
//
//  Created by jung on 4/25/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]

public protocol ParameterEncoding {
  func encode(
    _ urlRequest: URLRequest,
    with parameters: Parameters?
  ) throws -> URLRequest
}
