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
}
