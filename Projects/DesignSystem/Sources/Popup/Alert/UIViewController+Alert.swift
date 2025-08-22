//
//  UIViewController+Alert.swift
//  DesignSystem
//
//  Created by jung on 10/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

public extension UIViewController {
  @discardableResult
  func presentNetworkUnstableAlert(reason: String? = nil) -> AlertViewController {
    let alertVC = AlertViewController(
      alertType: .confirm,
      title: "네트워크가 불안정해요",
      subTitle: reason ?? "네트워크가 불안정합니다.\n 잠시 후에 다시 시도해주세요."
    )
    alertVC.present(to: self, animted: true)
    
    return alertVC 
  }
}
