//
//  URLEncoding.swift
//  AlloonNetwork
//
//  Created by jung on 4/25/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public struct URLEncoding: ParameterEncoding {
  public enum Destination {
    /// 파라미터를 인코딩된 query string으로 전송합니다.
    case queryString
    
    /// 파라미터를 `URLReqeust`의 body에 저장해 전송합니다.
    case httpBody
  }
  
  static var queryString: URLEncoding { URLEncoding() }
  static var httpBody: URLEncoding { URLEncoding(destination: .httpBody) }
  
  private let destination: Destination
  
  public init(destination: Destination = .queryString) {
    self.destination = destination
  }
  
  public func encode(_ urlRequest: URLRequest, with parameters: Parameters?) throws -> URLRequest {
    guard let parameters else { return urlRequest }
    
    switch destination {
      case .queryString:
        return try encodingForQueryString(urlRequest, parameters: parameters)
      case .httpBody:
        return encodingForHttpBody(urlRequest, parameters: parameters)
    }
  }
}

// MARK: - Private Methods
private extension URLEncoding {
  func encodingForQueryString(
    _ urlRequest: URLRequest,
    parameters: Parameters
  ) throws -> URLRequest {
    var urlRequest = urlRequest
    
    guard let url = urlRequest.url else {
      throw NetworkError.parameterEncodingFailed(reason: .missingURL)
    }
    
    if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
      let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
      urlComponents.percentEncodedQuery = percentEncodedQuery
      urlRequest.url = urlComponents.url
    }
    
    return urlRequest
  }
  
  func encodingForHttpBody(
    _ urlRequest: URLRequest,
    parameters: Parameters
  ) -> URLRequest {
    var urlRequest = urlRequest
    
    if urlRequest.headers["Content-Type"] == nil {
      urlRequest.headers.update(.contentType("application/x-www-form-urlencoded; charset=utf-8"))
    }
    
    urlRequest.httpBody = Data(query(parameters).utf8)
    
    return urlRequest
  }
  
  func escape(_ string: String) -> String {
    string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
  }
  
  func query(_ parameters: [String: Any]) -> String {
    var components: [(String, String)] = []
    
    for key in parameters.keys.sorted(by: <) {
      let value = parameters[key]!
      components.append((escape(key), escape("\(value)")))
    }
    
    return components.map { "\($0)=\($1)" }.joined(separator: "&")
  }
}
