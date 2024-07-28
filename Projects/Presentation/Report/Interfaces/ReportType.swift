//
//  ReportType.swift
//  HomeImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public enum ReportType {
  case challenge
  case feed
  case member
  
  public var contents: [String] {
    switch self {
      case .challenge:
        [
          "중복 / 도배성 챌린지",
          "음란성 / 선정적인 챌린지",
          "욕설 / 혐오 발언 챌린지",
          "폭력적 / 위험한 챌린지",
          "상업적 홍보 / 광고 챌린지",
          "타인을 비방하는 챌린지",
          "직접 작성"
        ]
      case .feed:
        [
          "중복 / 도배성 피드",
          "음란성 / 선정적인 피드",
          "욕설 / 혐오 발언 피드",
          "폭력적 / 위험한 피드",
          "상업적 홍보 / 광고 피드",
          "타인을 비방하는 피드",
          "직접 작성"
        ]
      case .member:
        [
          "중복 / 도배를 해요",
          "음란성 / 선정적인 이야기를 해요",
          "욕설 / 혐오적인 이야기를 해요",
          "폭력적 / 위협적인 이야기를 해요",
          "상업적 홍보 / 광고를 해요",
          "타인을 비방해요",
          "직접 작성"
        ]
    }
  }
}
