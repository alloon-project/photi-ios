//
//  NSAttributedString+Extension.swift
//  Core
//
//  Created by jung on 5/2/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public extension NSAttributedString {
  func setValue(_ value: Any, for key: NSAttributedString.Key) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(attributedString: self)
    
    attributedString.addAttribute(
      key,
      value: value,
      range: NSRange(location: 0, length: attributedString.length)
    )
    
    return attributedString
  }
  
  func setUnderLine() -> NSAttributedString {
    return setValue(NSUnderlineStyle.single.rawValue, for: .underlineStyle)
  }
  
  func setColor(_ color: UIColor) -> NSAttributedString {
    return setValue(color, for: .foregroundColor)
  }
}
