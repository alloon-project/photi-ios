//
//  UIImageWrapper.swift
//  Core
//
//  Created by jung on 2/25/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit

public final class UIImageWrapper {
  public var image: UIImage
  
  public init(image: UIImage) {
    self.image = image
  }
  
  public func imageToData(maxMB: Int) -> (image: Data, type: String)? {
    let maxSizeBytes = maxMB * 1024 * 1024
    
    if let data = self.image.pngData(), data.count <= maxSizeBytes {
      return (data, "png")
    } else if let data = self.image.converToJPEG(maxSizeMB: 8) {
      return (data, "jpeg")
    }
    return nil
  }
}
