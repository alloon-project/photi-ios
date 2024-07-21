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
public enum PhotiProgressPercent {
  case percent20
  case percent40
  case percent60
  case percent80
  case percent100
  case percent0
}
