//
//  PresignedImageUploader.swift
//  Repository
//
//  Created by jung on 12/10/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public enum ImageType: String {
  case jpeg
  case png
}

public protocol PresignedImageUploader {
  func upload(image: Data, imageType: ImageType) async throws -> String
}
