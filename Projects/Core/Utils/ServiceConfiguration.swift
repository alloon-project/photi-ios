//
//  ServiceConfiguration.swift
//  Core
//
//  Created by jung on 8/13/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public final class ServiceConfiguration {
  public static let shared = ServiceConfiguration()
  
  private init() { }
  
  public var baseUrl: URL {
    guard let baseUrl = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else {
      fatalError("Service API URL could not find in plist. Please check plist or user-defined!")
    }
    return URL(string: baseUrl)!
  }
  
  /// 사용자의 `userName`을 리턴합니다.
  public var userName: String {
    guard let name = UserDefaults.standard.string(forKey: "userName") else {
      return ""
    }
    
    return name
  }
  
  public func setUserName(_ name: String) {
    UserDefaults.standard.set(name, forKey: "userName")
  }
}
