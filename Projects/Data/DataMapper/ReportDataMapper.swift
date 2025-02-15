//
//  ReportDataMapper.swift
//  Data
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DTO

public protocol ReportDataMapper {
  func mapToReportRequestDTO(category: String, reason: String, content: String) -> ReportRequestDTO
}

public struct ReportDataMapperImpl: ReportDataMapper {
  public init() {}
  
  public func mapToReportRequestDTO(category: String, reason: String, content: String) -> ReportRequestDTO {
    return ReportRequestDTO(category: category, reason: reason, content: content)
  }
}
