//
//  PaginationResultType.swift
//  Repository
//
//  Created by jung on 5/29/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct PaginationResultType<T> {
  public let contents: [T]
  public let isLast: Bool
  
  public init(contents: [T], isLast: Bool) {
    self.contents = contents
    self.isLast = isLast
  }
}
