//
//  UIViewController+ToastView.swift
//  DesignSystem
//
//  Created by jung on 8/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit

public extension UIViewController {
  func presentNetworkUnstableToastView() {
    let toastView = ToastView(tipPosition: .none, text: "네트워크가 불안정해요. 다시 시도해주세요.", icon: .closeCircleRed)
    
    toastView.setConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(64)
    }
    
    toastView.present(to: self)
  }
}
