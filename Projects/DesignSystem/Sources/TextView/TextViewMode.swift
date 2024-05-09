//
//  TextViewMode.swift
//  DesignSystem
//
//  Created by jung on 5/9/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

/// TextView의 상태를 나타냅니다. (ex. `default`, `success`...)
public enum TextViewMode {
  case `default`
  case success
  case error
}

/// TextView의 Type을 나타냅니다. (ex. `default`, `helper` ...)
public enum TextViewType {
  case `default`
  case helper
  case count(_ max: Int)
}
