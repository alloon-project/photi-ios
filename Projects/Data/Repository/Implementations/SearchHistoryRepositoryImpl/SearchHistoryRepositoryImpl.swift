//
//  SearchHistoryRepositoryImpl.swift
//  DTO
//
//  Created by jung on 5/29/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Repository

public final class SearchHistoryRepositoryImpl: SearchHistoryRepository {
  private let userDefaults: UserDefaults
  private let key = "recentSearchKeywords"
  
  public init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }
}

public extension SearchHistoryRepositoryImpl {
  func save(keywords: [String]) {
    userDefaults.set(keywords, forKey: key)
  }
  
  func remove(keyword: String) -> [String] {
    let filtered = fetchAll().filter { $0 != keyword }
    userDefaults.set(filtered, forKey: key)
    return filtered
  }
  
  func fetchAll() -> [String] {
    return userDefaults.stringArray(forKey: key) ?? []
  }
  
  func removeAll() {
    userDefaults.removeObject(forKey: key)
  }
}
