//
//  BaseResponse.swift
//  AlloonNetwork
//
//  Created by jung on 4/25/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public struct BaseResponse<ResponseType: Decodable> {
  public let data: ResponseType
  public let statusCode: Int
  public let response: HTTPURLResponse?
  
  public var headers: [String: String] {
    guard let response else { return [:] }
    
    return response.headers.dictionary
  }
  
  public init(
    data: ResponseType,
    statusCode: Int,
    response: HTTPURLResponse? = nil
  ) {
    self.data = data
    self.statusCode = statusCode
    self.response = response
  }
}

public struct VoidResponse: Decodable { }
