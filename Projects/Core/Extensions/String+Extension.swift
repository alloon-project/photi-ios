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
    letterSpacing: CGFloat = -0.025,
    lineHeight: CGFloat? = nil
  ) -> NSAttributedString {
    let lineHeight = lineHeight ?? font.lineHeight
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment
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
  
  /// count만큼의 Suffix를 return 합니다.
  /// ex) "01234".trimmingSuffix(count: 2) == "01"
  func trimmingSuffix(count: Int) -> String {
    guard self.count >= count else { return self }
    
    let index = self.index(self.startIndex, offsetBy: count)
    return String(self[..<index])
  }
  
  func toDate(_ dateFormat: String = "YYYY.MM.dd") -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    
    return dateFormatter.date(from: self)
  }
}
