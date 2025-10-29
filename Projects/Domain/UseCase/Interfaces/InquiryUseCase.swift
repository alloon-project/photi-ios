//
//  InquiryUseCase.swift
//  Domain
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift

public protocol InquiryUseCase {
  func inquiry(type: String, content: String) async throws -> Void
}
