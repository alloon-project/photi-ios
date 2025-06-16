//
//  ReportType.swift
//  HomeImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public enum ReportType {
  case challenge(_ id: Int)
  case member(_ id: Int)
  case feed(_ id: Int)
  case inquiry
  
  public var title: String {
    switch self {
    case .challenge:
      "챌린지를 신고하는 이유가 무엇인가요?"
    case .member:
      "파티원을 신고하는 이유가 무엇인가요?"
    case .feed:
      "피드를 신고하는 이유가 무엇인가요?"
    case .inquiry:
      "문의 내용이 무엇인가요?"
    }
  }
  
  public var contents: [String] {
    switch self {
    case .challenge:
      ["중복 / 도배성 챌린지",
       "음란성 / 선정적인 챌린지",
       "욕설 / 혐오 발언 챌린지",
       "폭력적 / 위험한 챌린지",
       "상업적 홍보 / 광고 챌린지",
       "타인을 비방하는 챌린지",
       "직접 작성"]
    case .member:
      ["중복 / 도배를 해요",
       "음란성 / 선정적인 이야기를 해요",
       "욕설 / 혐오적인 이야기를 해요",
       "폭력적 / 위험적인 이야기를 해요",
       "상업적 홍보 / 광고를 해요",
       "타인을 비방해요",
       "직접 작성"]
    case .feed:
      ["중복 / 도배성 피드",
       "음란성 / 선정적인 피드",
       "욕설 / 혐오 발언 피드",
       "폭력적 / 위험한 피드",
       "상업적 홍보 / 광고 피드",
       "타인을 비방하는 피드",
       "직접 작성"]
    case .inquiry:
      ["서비스 이용 문의",
       "개선 / 제안 요청",
       "오류 문의",
       "기타 문의"]
    }
  }
  
  public var reason: [String] {
    switch self {
    case .challenge, .member, .feed:
      ["REDUNDANT",
       "OBSCENITY",
       "ABUSIVE",
       "DANGEROUS",
       "PROMOTION",
       "SLANDER",
       "ETC"]
    case .inquiry:
      ["SERVICE_USE",
       "SUGGESTION",
       "ERROR",
       "ETC"]
    }
  }
  
  public var textViewTitle: String {
    switch self {
    case .challenge, .feed, .member:
      "자세한 내용을 적어주시면 신고에 도움이 돼요"
    case .inquiry:
      "자세한 내용을 적어주세요"
    }
  }
  
  public var textViewPlaceholder: String {
    switch self {
    case .challenge, .feed, .member:
      "신고 내용을 상세히 알려주세요"
    case .inquiry:
      "문의 내용을 상세히 알려주세요"
    }
  }
  
  public var buttonTitle: String {
    switch self {
    case .challenge, .feed, .member:
      "신고하기"
    case .inquiry:
      "제출하기"
    }
  }
  
  public var category: String? {
    switch self {
    case .challenge:
      "CHALLANGE"
    case .member:
      "CHALLENGE_MEMBER"
    case .feed:
      "FEED"
    case .inquiry:
      nil
    }
  }
}
