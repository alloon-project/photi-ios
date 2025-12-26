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
  private let session: Session = {
    let config = URLSessionConfiguration.ephemeral
    config.httpAdditionalHeaders = [:]
    config.httpCookieStorage = nil
    config.httpShouldSetCookies = false

    let session = URLSession(configuration: config)
    return Session(session: session)
  }()
  
  private let provider: Provider<PresignedImageAPI>
  
  public init() {
    self.provider = Provider(session: session)
  }

  public func upload(image: Data, imageType: ImageType, uploadType: UploadType) async throws -> String {
    let filename = UUID().uuidString + ".\(imageType.rawValue)"
    let url = try await getPresignedURL(filename: filename, uploadType: uploadType)
    try await upload(image: image, type: imageType, at: url)
    return url
  }
}

// MARK: - Private Methods
private extension PresignedImageUploaderImpl {
  func getPresignedURL(filename: String, uploadType: UploadType) async throws -> String {
    let api = PresignedImageAPI.getPresignedURL(filename: filename, uploadType: uploadType.rawValue)
    let response = try await provider.request(api, type: PresignedImageResponseDTO.self)
    
    guard let dto = response.data else { throw APIError.serverError }
    
    return dto.presignedURL
  }
  
  func upload(image: Data, type: ImageType, at path: String) async throws {
    guard let url = URL(string: path) else { throw APIError.serverError }
    let response = try await provider.request(
      .postImage(path: url, data: image, imgType: type.rawValue),
      type: VoidResponseDTO.self
    )
    
    guard response.statusCode == 200 else { throw APIError.serverError }
  }
}
