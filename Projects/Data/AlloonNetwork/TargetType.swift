//
//  TargetType.swift
//  AlloonNetwork
//
//  Created by jung on 4/24/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public protocol TargetType {
  /// Base URL 정보입니다.
  var baseURL: URL { get }
  
  /// BaseURL뒤에 상세 경로를 입력합니다.
  var path: String { get }

  var method: HTTPMethod { get }
  
  /// 수행할 HTTP Task의 타입을 작성합니다.
  var task: TaskType { get }
    
  var headers: HTTPHeaders { get }
  
  /// 사용할 Stub Data를 입력합니다. default는 `Data()`입니다.
  var sampleResponse: EndpointSampleResponse { get }
}

public extension TargetType {
  var sampleResponse: EndpointSampleResponse { .networkResponse(200, Data(), "", "") }
  var headers: HTTPHeaders { .init() }
}
