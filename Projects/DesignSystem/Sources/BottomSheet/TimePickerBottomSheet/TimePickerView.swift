//
//  TimePickerView.swift
//  DesignSystem
//
//  Created by jung on 7/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

final class TimePickerView: UIPickerView {
  var customBackgroundColor = UIColor.black
  
  override func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)
    
    if newWindow != nil {
      inputView?.backgroundColor = customBackgroundColor
    }
  }
}
