//
//  NSAttributedString+Extension.swift
//  Core
//
//  Created by jung on 5/2/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public extension NSAttributedString {
  static func attributes(
    font: UIFont,
    color: UIColor,
    alignment: NSTextAlignment = .left,
    lineBreadMode: NSLineBreakMode = .byTruncatingTail,
    letterSpacing: CGFloat = -0.025,
    lineHeight: CGFloat? = nil
  ) -> [NSAttributedString.Key: Any] {
    let lineHeight = lineHeight ?? font.lineHeight
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment
    paragraphStyle.maximumLineHeight = lineHeight
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = lineBreadMode
    
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
      .kern: font.pointSize * letterSpacing,
      .paragraphStyle: paragraphStyle,
      .baselineOffset: (lineHeight - font.lineHeight) / 4
    ]
    
    return attributes
  }
  
  func setValue(
    _ value: Any,
    for key: NSAttributedString.Key,
    range: NSRange
  ) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(attributedString: self)
    
    attributedString.addAttribute(
      key,
      value: value,
      range: range
    )
    
    return attributedString
  }
  
  func setUnderLine(for subString: String? = nil) -> NSAttributedString {
    var range = NSRange()
    if let subString = subString {
      range = (self.string as NSString).range(of: subString)
    } else {
      range = NSRange(location: 0, length: self.string.count)
    }
    
    return setValue(NSUnderlineStyle.single.rawValue, for: .underlineStyle, range: range)
  }
  
  func setColor(_ color: UIColor, for subString: String? = nil) -> NSAttributedString {
    var range = NSRange()
    if let subString = subString {
      range = (self.string as NSString).range(of: subString)
    } else {
      range = NSRange(location: 0, length: self.string.count)
    }
    
    return setValue(color, for: .foregroundColor, range: range)
  }
}
