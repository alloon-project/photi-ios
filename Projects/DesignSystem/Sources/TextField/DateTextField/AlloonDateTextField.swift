//
//  AlloonDateTextField.swift
//  DesignSystem
//
//  Created by jung on 5/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

final class AlloonDateTextField: AlloonTextField {
  var currentText = ""

  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    !isFirstResponder
  }
  
  // 커서 조작시, 텍스트 끝으로 고정
  override func closestPosition(to point: CGPoint) -> UITextPosition? {
    let beginning = self.beginningOfDocument
    let textcount = currentText.isEmpty ? 0 : currentText.count

    let position = self.position(from: beginning, offset: textcount)
    
    if let position = position {
      self.selectedTextRange = textRange(from: position, to: position)
    }
    
    return position
  }
}
