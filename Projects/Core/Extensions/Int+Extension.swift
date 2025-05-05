//
//  Int+Extension.swift
//  Core
//
//  Created by 임우섭 on 4/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public extension Int {
  func hourToTimeString() -> String? {
    if self < 0 && self > 24 { return nil }
    if self < 10 {
      return "0\(self):00"
    } else {
      return "\(self):00"
    }
  }
}
