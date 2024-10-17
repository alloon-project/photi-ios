//
//  ChallengeRepository.swift
//  Entity
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import Entity

public protocol ChallengeRepository {
  init(dataMapper: ChallengeDataMapper)
    
  func fetchPopularChallenges() -> Single<[Challenge]>
}
