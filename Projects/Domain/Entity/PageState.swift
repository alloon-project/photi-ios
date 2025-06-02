//
//  PageState.swift
//  Entity
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public enum PageState<T> {
  case `defaults`([T])
  case lastPage([T])
  
  public var values: [T] {
    switch self {
      case .defaults(let values), .lastPage(let values):
        return values
    }
  }
}
