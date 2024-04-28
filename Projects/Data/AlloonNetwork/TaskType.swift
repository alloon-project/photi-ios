//
//  TaskType.swift
//  AlloonNetwork
//
//  Created by jung on 4/24/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

/// HTTP Task
public enum TaskType {
  /// 추가적인 Data없이 request를 합니다.
  case requestPlain
  
  /// request body에 파라미터로 전달된 `Data`타입을 저장합니다.
  case requestData(Data)
  
  /// request body에 `Encodable`을 json 형태로 저장합니다.
  case requestJSONEncodable(Encodable)
  
  /// request body에 `Encodable`을  custom encoder를 통해 저장합니다.
  case requestCustomJSONEncodable(Encodable, encoder: JSONEncoder)
  
  /// request에 `parameters`를 저장합니다. `encoding`을 통해 URL인지 JSON인지 결정할 수 있습니다.
  case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
  
  /// request body에 data를 저장하고, , `urlParameters`를 저장합니다.
  case requestCompositeData(bodyData: Data, urlParameters: [String: Any])
  
  /// request body에 `bodyParameters`를 저장하고, `urlParameters`를 저장합니다.
  case requestCompositeParameters(bodyParameters: [String: Any], urlParameters: [String: Any])
}
