//
//  Encodable+Extension.swift
//  AlloonNetwork
//
//  Created by jung on 4/28/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public extension Encodable {
  var toDictionary: [String: Any] {
    var dictionary = [String: Any]()
    
    let reflect = Mirror(reflecting: self)
    reflect.children.forEach { (key, value) in
      if let key = key {
        dictionary[key] = value
      }
    }
    
    return dictionary
  }
  
  func toDictionary(excludeKey: String...) -> [String: Any] {
    var dictionary = self.toDictionary

    excludeKey.forEach { dictionary.removeValue(forKey: $0) }
    return dictionary
  }
  
  func toDictionary(includeKey: String ...) -> [String: Data] {
    let originDictionary = self.toDictionary
    var dictionary = [String: Data]()
    
    includeKey.forEach {
        if let value = originDictionary[$0] as? Data {
          dictionary[$0] = value
      }
    }
    
    return dictionary
  }
}
