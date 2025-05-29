//
//  MultipartEncoding.swift
//  AlloonNetwork
//
//  Created by jung on 4/28/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public protocol MultipartUploadable {
  func encode(
    _ urlRequest: URLRequest,
    with multiParts: MultipartFormData?
  ) -> URLRequest
}

public struct MultipartEncoding: MultipartUploadable {
  fileprivate let crlf = "\r\n"
  
  public static let `default` = MultipartEncoding()

  public func encode(_ urlRequest: URLRequest, with multiParts: MultipartFormData?) -> URLRequest {
    var urlRequest = urlRequest
    
    guard let multiParts else { return urlRequest }
    
    if urlRequest.headers["Content-Type"] == nil {
      urlRequest.headers.update(.contentType("multipart/form-data; boundary=\(multiParts.boundary)"))
    }
    urlRequest.httpBody = encodeBodyParts(multiParts: multiParts)
    
    return urlRequest
  }
}

// MARK: - Private Extension
private extension MultipartEncoding {
  func encodeBodyParts(multiParts: MultipartFormData) -> Data {
    var data = Data()
    multiParts.bodyParts.forEach { bodyPart in
      switch bodyPart.type {
        case let .parameters(dictionaries):
          dictionaries.forEach { (key, value) in
            data.appendString("--\(multiParts.boundary)\(crlf)")
            data.append(encodeParameter(key: key, value: value))
          }
        case let .data(dictionaries):
          dictionaries.forEach { (key, value) in
            data.appendString("--\(multiParts.boundary)\(crlf)")
            let encodedData = encodedData(
              key: key,
              data: value,
              fileExtension: bodyPart.fileExtension,
              mimeType: bodyPart.mimeType
            )
            data.append(encodedData)
          }
        case let .jsonString(key, json):
          data.appendString("--\(multiParts.boundary)\(crlf)")
          let encodedData = encodeJSONString(key: key, value: json)
          data.append(encodedData)
      }
    }
    data.appendString("--\(multiParts.boundary)--\(crlf)")

    return data
  }
  
  func encodeParameter(key: String, value: Any) -> Data {
    var endcodedData = Data()
    endcodedData.appendString("Content-Disposition: form-data; name=\"\(key)\"")
    endcodedData.appendString("\(crlf)\(crlf)")
    endcodedData.appendString("\(value)")
    endcodedData.appendString(crlf)
    
    return endcodedData
  }
  
  func encodeJSONString(key: String, value: String) -> Data {
    var endcodedData = Data()
    endcodedData.appendString("Content-Disposition: form-data; name=\"\(key)\"")

    endcodedData.appendString("\(crlf)\(crlf)")
    endcodedData.appendString(value)
    endcodedData.appendString(crlf)
    
    return endcodedData
  }
  
  func encodedData(key: String, data: Data, fileExtension: String?, mimeType: String?) -> Data {
    var endcodedData = Data() 
    let fileExtension = fileExtension ?? ""
    let mimeType = mimeType ?? ""
    
    endcodedData.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).\(fileExtension)\"")
    endcodedData.appendString(crlf)
    endcodedData.appendString("Content-Type: \(mimeType)")
    endcodedData.appendString("\(crlf)\(crlf)")
    endcodedData.append(data)
    endcodedData.appendString(crlf)
    
    return endcodedData
  }
}

// MARK: - Data Extension
fileprivate extension Data {
  mutating func appendString(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    self.append(data)
  }
}
