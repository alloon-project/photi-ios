//
//  JSONEncoding.swift
//  AlloonNetwork
//
//  Created by jung on 4/25/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public struct JSONEncoding: ParameterEncoding {
  private enum Error: Swift.Error {
    case invalidJSONObject
  }
  
  public static var `default`: JSONEncoding { JSONEncoding() }
  
  public func encode(_ urlRequest: URLRequest, with parameters: Parameters?) throws -> URLRequest {
    var urlRequest = urlRequest
    
    guard let parameters else { return urlRequest }
    
    guard JSONSerialization.isValidJSONObject(parameters) else {
      throw NetworkError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: Error.invalidJSONObject))
    }
    
    do {
      let data = try JSONSerialization.data(withJSONObject: parameters)
      
      if urlRequest.headers["Content-Type"] == nil {
        urlRequest.headers.update(.contentType("application/json"))
      }
      
      urlRequest.httpBody = data
    } catch {
      throw NetworkError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
    }
    
    return urlRequest
  }
}
