//
//  InquiryUseCase.swift
//  Domain
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Repository

public protocol InquiryUseCase {
  init(repository: InquiryRepository)
  
  func inquiry(type: String, content: String) -> Single<Void>
}
