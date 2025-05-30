//
//  SearchHistoryRepository.swift
//  Repository
//
//  Created by jung on 5/29/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public protocol SearchHistoryRepository {
  func save(keywords: [String])
  func remove(keyword: String) -> [String]
  func fetchAll() -> [String]
  func removeAll()
}
