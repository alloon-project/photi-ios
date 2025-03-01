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
      subTitle: reason ?? "네트워크가 불안정합니다\n. 잠시 후에 다시 시도해주세요."
    )
    alertVC.present(to: self, animted: false)
    
    return alertVC 
  }
  
  @discardableResult
  func presentLoginTriggerAlert() -> AlertViewController {
    let alertVC = AlertViewController(
      alertType: .canCancel,
      title: "재로그인이 필요해요",
      subTitle: "보안을 위해 자동 로그아웃 됐어요.\n다시 로그인해주세요."
    )
    alertVC.confirmButtonTitle = "로그인하기"
    alertVC.cancelButtonTitle = "나중에 할래요"
    
    return alertVC
  }
}
