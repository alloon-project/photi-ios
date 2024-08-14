//
//  ServiceConfiguration.swift
//  Core
//
//  Created by jung on 8/13/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct ServiceConfiguration {
  public static var baseUrl: String {
    guard let baseUrl = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else {
      fatalError("Service API URL could not find in plist. Please check plist or user-defined!")
    }
    return baseUrl
  }
}
