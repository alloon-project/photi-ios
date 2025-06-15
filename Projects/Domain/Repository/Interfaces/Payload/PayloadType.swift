//
//  PayloadType.swift
//  Domain
//
//  Created by 임우섭 on 6/10/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public enum PayloadType {
  case name(_ value: String)
  case isPublic(_ value: Bool)
  case goal(_ value: String)
  case proveTime(_ value: String)
  case endDate(_ value: String)
  case rules(_ value: [String])
  case hashtags(_ value: [String])
  case image(_ value: Data)
  case imageType(_ value: String)
}
