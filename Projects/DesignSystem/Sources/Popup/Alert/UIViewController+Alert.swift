//
//  UIViewController+Alert.swift
//  DesignSystem
//
//  Created by jung on 10/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

public extension UIViewController {
  func presentWarningPopup() {
    let alertVC = AlertViewController(alertType: .confirm, title: "오류", subTitle: "서버가 불안정합니다. 잠시 후에 다시 시도해주세요.")
    alertVC.present(to: self, animted: false)
  }
}
