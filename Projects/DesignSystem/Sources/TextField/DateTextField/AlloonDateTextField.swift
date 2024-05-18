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
  
  // 커서 조작시, 텍스트 끝으로 고정
  override func closestPosition(to point: CGPoint) -> UITextPosition? {
    let beginning = self.beginningOfDocument
    let textcount = currentText.isEmpty ? 0 : currentText.count
    let end = self.position(from: beginning, offset: textcount)
    
    return end
  }
  
  // 붙여넣기, select 안되도록 설정.
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if
      action == #selector(UIResponderStandardEditActions.paste(_:)) ||
        action == #selector(UIResponderStandardEditActions.select(_:)) {
      return false
    }
    
    return super.canPerformAction(action, withSender: sender)
  }
  
  // Selection안되도록 설정.
  override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
    return []
  }
}
