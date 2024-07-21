//
//  MultipartFormData.swift
//  AlloonNetwork
//
//  Created by jung on 4/28/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

fileprivate let crlf = "\n\r"

// MARK: - MultipartFormData
public struct MultipartFormData {
  public let boundary: String
  public var bodyParts: [MultipartFormDataBodyPart]
  
  public init(bodyParts: [MultipartFormDataBodyPart], boundary: String? = nil) {
    self.bodyParts = bodyParts
    self.boundary = boundary ?? BoundaryGenerator.randomBoundary()
  }
  
  public init(boundary: String? = nil) {
    self.init(bodyParts: [], boundary: boundary)
  }
}

// MARK: - MultipartFormDataBodyPart
public struct MultipartFormDataBodyPart {
  public enum BodyType {
    // 일반적인 파라미터를 저장합니다.
    case parameters([String: Any])
    // file, image 등 데이터를 저장합니다.
    case data([String: Data])
  }
  
  public let type: BodyType
  
  /// mimeType을 저장합니다.
  public let mimeType: String?
  
  /// 파일의 확장자입니다 ex) jpg, png, txt ...
  public let fileExtension: String?
  
  public init(_ type: BodyType, fileExtension: String? = nil, mimeType: String? = nil) {
    self.type = type
    self.fileExtension = fileExtension
    self.mimeType = mimeType
  }
}

// MARK: - BoundaryGenerator
fileprivate enum BoundaryGenerator {
  enum BoundaryType {
     case initial, encapsulated, final
   }
   
   static func randomBoundary() -> String {
     let first = UInt32.random(in: UInt32.min...UInt32.max)
     let second = UInt32.random(in: UInt32.min...UInt32.max)

     return String(format: "boundary.%08x%08x", first, second)
   }
   
   static func boundaryData(forBoundaryType boundaryType: BoundaryType, boundary: String) -> Data {
     let boundaryText: String
     
     switch boundaryType {
       case .initial:
         boundaryText = "--\(boundary)\(crlf)"
       case .encapsulated:
         boundaryText = "\(crlf)--\(boundary)\(crlf)"
       case .final:
         boundaryText = "\(crlf)--\(boundary)--\(crlf)"
     }
     
     return Data(boundaryText.utf8)
   }
 }
