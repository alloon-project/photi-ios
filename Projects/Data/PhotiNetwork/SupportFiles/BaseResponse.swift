//
//  BaseResponse.swift
//  AlloonNetwork
//
//  Created by jung on 4/25/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public struct BaseResponse<ResponseType: Decodable> {
  public let code: String
  public let message: String
  public let data: ResponseType?
  public let statusCode: Int
  public let response: HTTPURLResponse?
  
  public var headers: [String: String] {
    guard let response else { return [:] }
    
    return response.headers.dictionary
  }
  
  public init(
    dto: BaseResponseDTO<ResponseType>,
    statusCode: Int,
    response: HTTPURLResponse? = nil
  ) {
    self.code = "\(dto.code)"/*dto.code*/
    self.message = dto.message
    self.data = dto.data
    self.statusCode = statusCode
    self.response = response
  }
  
  public init(
    dto: VoidResponseDTO,
    statusCode: Int,
    response: HTTPURLResponse? = nil
  ) {
    self.data = nil
    self.code = dto.code
    self.message = dto.message
    self.statusCode = statusCode
    self.response = response
  }
}

/// 성공 시, ResponseType을 명시한 경우 BaseResponseDTO를 통해 디코딩 됩니다.
public struct BaseResponseDTO<ResponseType: Decodable>: Decodable {
  public let code: String
  public let message: String
  public let data: ResponseType
  
  public init(code: String, message: String, data: ResponseType) {
    self.code = code
    self.message = message
    self.data = data
  }
}

/// 실패시 VoidResponseDTO로 디코딩됩니다.
public struct VoidResponseDTO: Decodable {
  public let code: String
  public let message: String
  
  public init(code: String, message: String) {
    self.code = code
    self.message = message
  }
}

/// 성공시, ResponseType이 없는 경우 `data`필드에 해당 데이터가 들어갑니다.
public struct SuccessResponseDTO: Decodable {
  public let successMessage: String
  
  public init(successMessage: String) {
    self.successMessage = successMessage
  }
}
