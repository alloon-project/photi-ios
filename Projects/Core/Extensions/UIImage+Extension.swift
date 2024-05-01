//
//  UIImage+Extension.swift
//  Core
//
//  Created by jung on 5/1/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public extension UIImage {
  /// 지정한 size로 image를 resize한 `UIImage`객체를 리턴합니다.
  /// - Parameters: 
  ///   - size: resize할 size
  func resize(_ size: CGSize) -> UIImage {
    let image = UIGraphicsImageRenderer(size: size).image { _ in
      draw(in: CGRect(origin: .zero, size: size))
    }
    
    return image.withRenderingMode(renderingMode)
  }
}
