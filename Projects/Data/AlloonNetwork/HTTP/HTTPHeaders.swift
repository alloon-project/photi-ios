//
//  HTTPHeaders.swift
//  DTO
//
//  Created by jung on 4/22/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public struct HTTPHeaders {
  private var headers: [HTTPHeader]
  
  // MARK: - Initalizers
  public init() {
    self.headers = []
  }
  
  public init(_ headers: [HTTPHeader]) {
    self.init()
    headers.forEach { update($0) }
  }
  
  public init(_ dictionary: [String: String]) {
    self.init()
    dictionary.forEach { update(name: $0.key, value: $0.value) }
  }
}

// MARK: - Methods
public extension HTTPHeaders {
  mutating func add(name: String, value: String) {
    update(HTTPHeader(name: name, value: value))
  }
  
  mutating func add(_ header: HTTPHeader) {
    update(header)
  }
  
  mutating func update(name: String, value: String) {
    update(HTTPHeader(name: name, value: value))
  }
  
  mutating func update(_ header: HTTPHeader) {
    guard let index = headers.index(of: header.name) else {
      headers.append(header)
      return
    }
    
    headers.replaceSubrange(index...index, with: [header])
  }
  
  mutating func remove(name: String) {
    guard let index = headers.index(of: name) else { return }
    headers.remove(at: index)
  }
  
  mutating func sort() {
    headers.sort { $0.name.lowercased() < $1.name.lowercased() }
  }
  
  func sorted() -> HTTPHeaders {
    var headers = self
    headers.sort()
    
    return headers
  }
  
  func value(for name: String) -> String? {
    guard let index = headers.index(of: name) else { return nil }
    
    return headers[index].value
  }
  
  subscript(_ name: String) -> String? {
    get { value(for: name) }
    set {
      if let value = newValue {
        update(name: name, value: value)
      } else {
        remove(name: name)
      }
    }
  }
  
  var dictionary: [String: String] {
    let namesAndValues = headers.map { ($0.name, $0.value) }
    
    return Dictionary(namesAndValues) { _, last in last }
  }
}
