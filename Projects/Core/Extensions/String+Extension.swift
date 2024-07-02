//
//  String+Extension.swift
//  Core
//
//  Created by jung on 4/30/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public extension String {
  var isValidateId: Bool {
    self.matchesPattern(with: "^[a-z0-9!_@$%^&+=]+$")
  }
  
  func attributedString(
    font: UIFont,
    color: UIColor,
    alignment: NSTextAlignment = .left,
    letterSpacing: CGFloat = -0.025,
    lineHeight: CGFloat? = nil
  ) -> NSAttributedString {
    let attributes = NSAttributedString.attributes(
      font: font,
      color: color,
      alignment: alignment,
      letterSpacing: letterSpacing,
      lineHeight: lineHeight
    )
    
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
  
  /// 이메일 형식을 가지고 있는지 체크합니다.
  func isValidateEmail() -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    return  NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
  }
  /// 정규표현식을 통해 Pattern을 검사합니다.
  func matchesPattern(with regex: String) -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
  }
  
  func contain(_ regexString: String) -> Bool {
    guard let regex = try? NSRegularExpression(pattern: regexString, options: []) else {
      return false
    }
    
    let range = NSRange(location: 0, length: self.count)
    return regex.firstMatch(in: self, range: range) != nil
  }
}
