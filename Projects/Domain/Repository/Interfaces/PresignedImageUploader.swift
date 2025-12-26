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

public enum UploadType: String {
  case feed = "feeds"
  case userProfile = "users"
  case challengeProfile = "challenges"
}

public protocol PresignedImageUploader {
  func upload(image: Data, imageType: ImageType, uploadType: UploadType) async throws -> String
}
