//
//  NSAttributedString+Extension.swift
//  Core
//
//  Created by jung on 5/2/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public extension NSAttributedString {
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
