//
//  Interceptor.swift
//  DTO
//
//  Created by jung on 5/22/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public protocol RequestInterceptorType: RequestAdapter, RequestRetrier { }

/// `URLRequest` 에 특정 규칙 등을 추가하기 위한 타입입니다.
public protocol RequestAdapter {
    /// `URLRequest`에 특정 규칙을 적용한 새로운 `URLRequest`를 리턴합니다.
    ///
    /// - Parameters:
    ///   - urlRequest: 규칙을 적용할 `URLRequest`
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest
}

/// `URLRequest`가 재시도 필요한지 등의 규칙을 정의하기 위한 타입입니다.
public protocol RequestRetrier {
  /// `URLRequest`에 특정 규칙을 적용하여, `RetryResult`를 리턴하며 asynchronous하게 동작합니다.
  ///
  /// - Parameters:
  ///   - response: HTTP 통신에서의 Response입니다.
  ///   - data: HTTP 통신의 bodyData입니다.
  func retry(for response: HTTPURLResponse, data: Data) async -> RetryResult
}

/// `RequestRetrier`의 `retry`메서드의 리턴 타입입니다.
public enum RetryResult {
  /// Retry가 필요한 경우
  case retry
  /// Retry가 필요하지 않는 경우
  case doNotRetry
  /// `Error`때문에 Retry가 필요하지 않는 경우
  case doNotRetryWithError(Error)
}
