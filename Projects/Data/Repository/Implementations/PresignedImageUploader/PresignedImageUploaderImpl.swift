//
//  PresignedImageUploaderImpl.swift
//  DTO
//
//  Created by jung on 12/10/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import DTO
import Entity
import Repository
import PhotiNetwork

public final class PresignedImageUploaderImpl: PresignedImageUploader {
  private let provider = Provider<PresignedImageAPI>()
  
  public init() { }

  public func upload(image: Data, imageType: ImageType) async throws -> String {
    let filename = UUID().uuidString + ".\(imageType.rawValue)"
    do {
      let url = try await getPresignedURL(filename: filename)
      try await upload(image: image, at: url)
      return url
    } catch {
      throw error
    }
  }
}

// MARK: - Private Methods
private extension PresignedImageUploaderImpl {
  func getPresignedURL(filename: String) async throws -> String {
    let api = PresignedImageAPI.getPresignedURL(filename: filename)
    let response = try await provider.request(api, type: PresignedImageResponseDTO.self)
    
    guard let dto = response.data else { throw APIError.serverError }
    
    return dto.presignedURL
  }
  
  func upload(image: Data, at path: String) async throws {
    guard let url = URL(string: path) else { throw APIError.serverError }
    let response = try await provider.request(.postImage(path: url, data: image))
    
    guard response.statusCode == 200 else { throw APIError.serverError }
  }
}
