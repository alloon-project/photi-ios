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
  
  func color(_ color: UIColor) -> UIImage {
    return self.withTintColor(color, renderingMode: .alwaysOriginal)
  }
  
  func converToJPEG(maxSizeMB: Int) -> Data? {
    let maxSizeBytes = maxSizeMB * 1024 * 1024
    
    var compression: CGFloat = 1.0
    var jpegConvertedData = jpegData(compressionQuality: compression)
    
    while let data = jpegConvertedData, data.count > maxSizeBytes, compression > 0.1 {
      compression -= 0.1
      jpegConvertedData = jpegData(compressionQuality: compression)
    }
    
    if let jpegData = jpegConvertedData, jpegData.count <= maxSizeBytes {
      return jpegData
    } else {
      return nil
    }
  }
}
