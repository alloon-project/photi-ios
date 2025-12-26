//
//  Double+Extension.swift
//  Core
//
//  Created by jung on 12/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

public extension Double {
  func bound(lower: Double, upper: Double) -> Double {
    return min(max(self, lower), upper)
  }
}
