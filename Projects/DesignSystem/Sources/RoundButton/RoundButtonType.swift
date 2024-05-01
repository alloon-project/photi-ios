//
//  RoundButtonType.swift
//  DesignSystem
//
//  Created by jung on 4/30/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

/// RoundButton의 유형을 나타냅니다. (ex. primary..)
public enum RoundButtonType {
  case primary
  case secondary
  case tertiary
  case quaternary
}

/// RoundButton의 모드 및 상태를 나타냅니다.
public enum RoundButtonMode {
  case `default`
  case pressed
  case disabled
}

/// RoundButton의 size를 나타냅니다. 
public enum RoundButtonSize {
  case xLarge
  case large
  case medium
  case small
  case xSmall
}
