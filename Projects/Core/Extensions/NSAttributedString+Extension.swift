//
//  NSAttributedString+Extension.swift
//  Core
//
//  Created by jung on 5/2/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public extension NSAttributedString {
  func setColor(_ color: UIColor) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(attributedString: self)
    
    attributedString.addAttribute(
      .foregroundColor,
      value: color,
      range: NSRange(location: 0, length: attributedString.length)
    )
    
    return attributedString
  }
}
