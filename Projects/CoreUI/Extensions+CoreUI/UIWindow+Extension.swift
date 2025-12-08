//
//  UIWindow+Extension.swift
//  Core
//
//  Created by jung on 10/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

public extension UIWindow {
  /// 가장 상위의 `UIWindow`를 반환합니다.
  /// 찾지 못하였을 경우 `nil`을 반환합니다.
  static var key: UIWindow? {
    if #available(iOS 13, *) {
      return UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
    } else {
      return UIApplication.shared.keyWindow
    }
  }
}
