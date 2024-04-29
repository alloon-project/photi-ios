//
//  HTTPHeader.swift
//  DTO
//
//  Created by jung on 4/22/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

public struct HTTPHeader: Hashable {
  public let name: String
  public let value: String
  
  public init(name: String, value: String) {
    self.name = name
    self.value = value
  }
}

// MARK: - CustomStringConvertible
extension HTTPHeader: CustomStringConvertible {
  public var description: String {
    "\(name): \(value)"
  }
}

// MARK: - Static Methods
public extension HTTPHeader {
  /// `Content-Type` 헤더를 리턴합니다.
  static func contentType(_ value: String) -> HTTPHeader {
    HTTPHeader(name: "Content-Type", value: value)
  }
  
  /// `Authorization` 헤더를 리턴합니다.
  static func authorization(_ value: String) -> HTTPHeader {
    HTTPHeader(name: "Authorization", value: value)
  }
  
  /// `acessToken`을 통해 `Bearer` `Authorization` 헤더를 리턴합니다.
  static func authorization(acessToken: String) -> HTTPHeader {
    authorization("Bearer \(acessToken)")
  }
  
  /// `Refresh-Token`헤더를 리턴합니다.
  static func refreshToken(_ token: String) -> HTTPHeader {
    HTTPHeader(name: "Refresh-Token", value: "Bearer \(token)")
  }
}

extension [HTTPHeader] {
  func index(of name: String) -> Int? {
    let lowercasedName = name.lowercased()
    return firstIndex { $0.name.lowercased() == lowercasedName }
  }
}
