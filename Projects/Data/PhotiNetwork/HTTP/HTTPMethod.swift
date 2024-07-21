//
//  HTTPMethod.swift
//  DTO
//
//  Created by jung on 4/22/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

public struct HTTPMethod {
  /// `DELETE` method.
  public static let delete = HTTPMethod(rawValue: "DELETE")
  /// `GET` method.
  public static let get = HTTPMethod(rawValue: "GET")
  /// `PATCH` method.
  public static let patch = HTTPMethod(rawValue: "PATCH")
  /// `POST` method.
  public static let post = HTTPMethod(rawValue: "POST")
  /// `PUT` method.
  public static let put = HTTPMethod(rawValue: "PUT")
  
  public let rawValue: String
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}
