//
//  BaseURL.swift
//  AlloonNetwork
//
//  Created by jung on 6/1/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

struct URLString {
  let url: String
  
  static let base: URLString = {
    guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else {
      fatalError("url is not valid")
    }
    
    return URLString(url: baseURL)
  }()
}
