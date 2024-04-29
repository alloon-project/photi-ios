//
//  URLRequest+Extension.swift
//  DTO
//
//  Created by jung on 4/22/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

extension URLRequest {
  var headers: HTTPHeaders {
    get { allHTTPHeaderFields.map(HTTPHeaders.init) ?? HTTPHeaders() }
    set { allHTTPHeaderFields = newValue.dictionary }
  }
}

extension URLRequest {
  mutating func encoded(_ encodable: Encodable, encoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
    do {
      httpBody = try encoder.encode(encodable)
      
      let contentTypeHeaderName = "Content-Type"
      if value(forHTTPHeaderField: contentTypeHeaderName) == nil {
        setValue("application/json", forHTTPHeaderField: contentTypeHeaderName)
      }
      
      return self
    } catch {
      throw NetworkError.networkFailed(reason: .encodableMapping)
    }
  }
  
  func encoded(_ parameters: [String: Any], parameterEncoding: ParameterEncoding) throws -> URLRequest {
    do {
      return try parameterEncoding.encode(self, with: parameters)
    } catch {
      throw error
    }
  }
  
  func encoded(_ multiparts: MultipartFormData, multipartEncoding: MultipartEncoding = .default) -> URLRequest {
    return multipartEncoding.encode(self, with: multiparts)
  }
}
