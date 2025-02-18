//
//  ResginRepository.swift
//  Domain
//
//  Created by 임우섭 on 2/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import DataMapper

public protocol ResignRepository {
  init(dataMapper: ResignDataMapper)
  func resign(password: String) -> Single<Void>
}
