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
    alignment: NSTextAlignment = .left,
    lineBreakingMode: NSLineBreakMode = .byTruncatingTail,
    letterSpacing: CGFloat = -0.025,
    lineHeight: CGFloat? = nil
  ) -> NSAttributedString {
    let attributes = NSAttributedString.attributes(
      font: font,
      color: color,
      alignment: alignment,
      lineBreadMode: lineBreakingMode,
      letterSpacing: letterSpacing,
      lineHeight: lineHeight
    )
    
    return NSAttributedString(string: self, attributes: attributes)
  }
}
