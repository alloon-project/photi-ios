//
//  String+Extension.swift
//  Core
//
//  Created by jung on 4/30/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import DesignSystem

public extension String {
  func attributedString(
    font: UIFont,
    color: UIColor,
    letterSpacing: CGFloat = -0.025,
    lineHeight: CGFloat? = nil
  ) -> NSAttributedString {
    let lineHeight = lineHeight ?? self.lineHeight(for: font)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.maximumLineHeight = lineHeight
    paragraphStyle.minimumLineHeight = lineHeight
    
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
      .kern: font.pointSize * letterSpacing,
      .paragraphStyle: paragraphStyle,
      .baselineOffset: (lineHeight - font.lineHeight) / 4
    ]
    
    return NSAttributedString(string: self, attributes: attributes)
  }
}

// MARK: - Private Extension
private extension String {
  func lineHeight(for font: UIFont) -> CGFloat {
    switch font {
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
        return font.lineHeight
    }
  }
}
