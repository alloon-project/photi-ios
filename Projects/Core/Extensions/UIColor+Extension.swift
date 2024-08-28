//
//  UIColor+Extension.swift
//  Core
//
//  Created by wooseob on 8/27/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit.UIColor

extension UIColor {
  var hexString: String {
      let components = self.cgColor.components
      var red: CGFloat = 0.0
      var green: CGFloat = 0.0
      var blue: CGFloat = 0.0
      if components?.indices.contains(0) == true {
          red = components![0]
      }
      if components?.indices.contains(1) == true {
          green = components![1]
      }
      if components?.indices.contains(2) == true {
          blue = components![2]
      }
      
      let hexString = String.init(format: "#%02lX%02lX%02lX",
                                  lroundf(Float(red * 255)),
                                  lroundf(Float(green * 255)),
                                  lroundf(Float(blue * 255)))
      return hexString
  }
}
