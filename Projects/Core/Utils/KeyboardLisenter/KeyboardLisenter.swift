//
//  KeyboardLisenter.swift
//  Core
//
//  Created by jung on 1/3/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit

public protocol KeyboardListener {
  var keyboardShowNotification: NSObjectProtocol? { get set }
  var keyboardHideNotification: NSObjectProtocol? { get set }
  
  func keyboardWillShow(keyboardHeight: CGFloat)
  func keyboardWillHide()
}

public extension KeyboardListener where Self: UIViewController {
  @discardableResult
  func registerKeyboardShowNotification() -> NSObjectProtocol? {
    let showNotification = NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillShowNotification,
      object: nil,
      queue: nil
    ) { [weak self] notification in
      guard
        let userInfo = notification.userInfo,
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
      else { return }
      
      self?.keyboardWillShow(keyboardHeight: keyboardFrame.height)
    }
    return showNotification
  }
  
  @discardableResult
  func registerKeyboardHideNotification() -> NSObjectProtocol? {
    let hideNotification = NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillHideNotification,
      object: nil,
      queue: nil
    ) { [weak self] _ in
      self?.keyboardWillHide()
    }
    return hideNotification
  }
  
  func removeKeyboardNotification(_ notifications: NSObjectProtocol?...) {
    notifications.forEach(NotificationCenter.default.removeObserver(_:))
  }
}
