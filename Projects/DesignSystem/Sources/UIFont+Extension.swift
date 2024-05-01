//
//  String+Extension.swift
//  DesignSystem
//
//  Created by jung on 5/1/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public extension UIFont {
  func lineHeight() -> CGFloat {
    switch self {
      case .heading1:
        return 32
      case .heading2:
        return 30
      case .heading3:
        return 28
      case .heading4:
        return 25
      case .body1, .body1Bold:
        return 24
      case .body2, .body2Bold:
        return 22
      case .caption1, .caption1Bold:
        return 19
      case .caption2, .caption2Bold:
        return 16
      default:
        return lineHeight
    }
  }
}
