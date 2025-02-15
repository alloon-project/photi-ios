//
//  InquiryRepository.swift
//  Domain
//
//  Created by wooseob on 12/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper

public protocol InquiryRepository {
  init(dataMapper: InquiryDataMapper)
  
  func inquiry(type: String, content: String) -> Single<Void>
}
