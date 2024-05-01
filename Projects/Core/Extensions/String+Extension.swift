//
//  String+Extension.swift
//  Core
//
//  Created by jung on 4/30/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public extension String {
  func attributedString(
    font: UIFont,
    color: UIColor,
    letterSpacing: CGFloat = -0.025,
    lineHeight: CGFloat? = nil
  ) -> NSAttributedString {
    let lineHeight = lineHeight ?? font.lineHeight
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
