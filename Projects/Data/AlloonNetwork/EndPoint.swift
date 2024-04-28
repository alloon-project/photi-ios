//
//  EndPoint.swift
//  AlloonNetwork
//
//  Created by jung on 4/24/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

/// Stub response에 사용합니다.
public enum EndpointSampleResponse {
  /// status code와 data를 함께 리턴합니다.
  case networkResponse(Int, Data)
  
  /// 실패하는 경우, `NSError`와 함께 리턴합니다.
  case networkError(NSError)
}

struct EndPoint {
  let url: URL
  let task: TaskType
  let method: HTTPMethod
  let httpHeaderFields: HTTPHeaders?
  
  init(
    url: URL,
    method: HTTPMethod,
    task: TaskType,
    httpHeaderFields: HTTPHeaders?
  ) {
    self.url = url
    self.method = method
    self.task = task
    self.httpHeaderFields = httpHeaderFields
  }
}

extension EndPoint {
  func urlRequest() throws -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = httpHeaderFields?.dictionary
    
    switch task {
      case .requestPlain:
        return request
        
      case let .requestData(data):
        request.httpBody = data
        return request
        
      case let .requestJSONEncodable(encodable):
        return try request.encoded(encodable)
        
      case let .requestCustomJSONEncodable(encodable, encoder):
        return try request.encoded(encodable, encoder: encoder)
        
      case let .requestParameters(parameters, encoding):
        return try request.encoded(parameters, parameterEncoding: encoding)
      
      case let .requestCompositeData(bodyData, urlParameters):
        request.httpBody = bodyData
        return try request.encoded(urlParameters, parameterEncoding: URLEncoding.queryString)
        
      case let .requestCompositeParameters(bodyParameters, urlParameters):
        request = try request.encoded(bodyParameters, parameterEncoding: URLEncoding.httpBody)
        return try request.encoded(urlParameters, parameterEncoding: URLEncoding.queryString)
        
      case let .uploadMultipartFormData(multipart):
        return request.encoded(multipart)
    }
  }
}
