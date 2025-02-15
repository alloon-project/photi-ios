//
//  InquiryDataMapper.swift
//  Data
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DTO

public protocol InquiryDataMapper {
  func mapToInquiryRequestDTO(type: String, content: String) -> InquiryRequestDTO
}

public struct InquiryDataMapperImpl: InquiryDataMapper {
  public init() {}
  
  public func mapToInquiryRequestDTO(type: String, content: String) -> InquiryRequestDTO {
    return InquiryRequestDTO(type: type, content: content)
  }
}
