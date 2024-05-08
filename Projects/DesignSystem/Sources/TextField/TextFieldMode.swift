//
//  TextFieldMode.swift
//  DesignSystem
//
//  Created by jung on 5/7/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

/// TextField의 상태를 나타냅니다. (ex. `default`, `success`...)
public enum TextFieldMode {
  case `default`
  case success
  case error
}

/// TextField의 Type을 나타냅니다. (ex. `default`, `helper` ...)
public enum TextFieldType {
  case `default`
  case helper
  case count(_ max: Int)
}
