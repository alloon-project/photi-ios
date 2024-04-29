//
//  HTTPURLResponse+Exteision.swift
//  AlloonNetwork
//
//  Created by jung on 4/25/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public extension HTTPURLResponse {
  var headers: HTTPHeaders {
    (allHeaderFields as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders()
  }
}
