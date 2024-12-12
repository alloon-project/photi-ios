//
//  ProgressValueType.swift
//  DesignSystem
//
//  Created by wooseob on 5/16/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

/// Large Type의 진행상태 값 분류입니다. 나타냅니다. (ex. one, two, ..., five)
public enum PhotiProgressStep {
  case one
  case two
  case three
  case four
  case five
}
/// Medium Type의 진행상태 값 분류입니다. 나타냅니다. (ex. percent0, percent20, ..., percent100)
public enum PhotiProgressPercent: Double {
  case percent0 = 0
  case percent20 = 0.2
  case percent40 = 0.4
  case percent60 = 0.6
  case percent80 = 0.8
  case percent100 = 1
  
  public init(_ percent: Double) {
    if percent < 0.1 {
      self = .percent0
    } else if percent < 0.3 {
      self = .percent20
    } else if percent < 0.5 {
      self = .percent40
    } else if percent < 0.7 {
      self = .percent60
    } else if percent < 0.9 {
      self = .percent80
    } else {
      self = .percent100
    }
  }
}
