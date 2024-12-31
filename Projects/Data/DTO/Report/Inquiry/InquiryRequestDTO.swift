//
//  InquiryRequestDTO.swift
//  Data
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct InquiryRequestDTO: Encodable {
  /// 문의 타입
  ///
  /// ex) SERVICE_USE, SUGGESTION, ERROR, ETC
  public let type: String
  /// 문의 내용 (maxLength: 120, minLength: 1)
  public let content: String
  
  public init(type: String, content: String) {
    self.type = type
    self.content = content
  }
}
