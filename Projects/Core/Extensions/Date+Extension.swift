//
//  Date+Extension.swift
//  Core
//
//  Created by jung on 5/16/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public extension Date {
  var year: Int {
    let component = Calendar.current.dateComponents([.year], from: self)
    
    return component.year ?? 0
  }
  
  var month: Int {
    let component = Calendar.current.dateComponents([.month], from: self)
    
    return component.month ?? 0
  }
  
  var day: Int {
    let component = Calendar.current.dateComponents([.day], from: self)
    
    return component.day ?? 0
  }
  
  func toString() -> String {
    let monthText = month < 10 ? "0\(month)" : "\(month)"
    let dayText = day < 10 ? "0\(day)" : "\(day)"
    return "\(year).\(monthText).\(dayText)"
  }
}
