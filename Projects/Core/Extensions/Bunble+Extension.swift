//
//  Bunble+Extension.swift
//  Core
//
//  Created by jung on 6/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public extension Bundle {
  static var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  }
}
