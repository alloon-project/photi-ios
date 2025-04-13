//
//  Int+Extension.swift
//  Core
//
//  Created by 임우섭 on 4/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public extension Int {
  func hourToTimeString() -> String {
      var components = DateComponents()
      components.hour = self
      components.minute = 0
      
      let calendar = Calendar.current
      if let date = calendar.date(from: components) {
          let formatter = DateFormatter()
          formatter.dateFormat = "HH:mm"
          return formatter.string(from: date)
      }
      
      return "Invalid"
  }
}
