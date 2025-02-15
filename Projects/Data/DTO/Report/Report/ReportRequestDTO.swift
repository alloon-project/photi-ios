//
//  ReportRequestDTO.swift
//  Data
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public struct ReportRequestDTO: Encodable {
  /// 신고 타입
  ///
  /// ex) CHALLENGE, CHALLENGE_MEMBER, FEED
  public let category: String
  
  /// 신고 이유
  ///
  /// REDUNDANT, OBSENITY, ABUSIVE, DANGEROUS, PROMOTION, SLANDER, ETC
  public let reason: String
  
  /// 신고 내용 (maxLength: 120, minLength: 0)
  public let content: String
  
  public init(category: String, reason: String, content: String) {
    self.category = category
    self.reason = reason
    self.content = content
  }
}
