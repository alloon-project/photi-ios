//
//  EndedChallengeRepository.swift
//  Domain
//
//  Created by 임우섭 on 11/3/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import Entity

public protocol EndedChallengeRepository {
  init (dataMapper: EndedChallengeDataMapper)
  
  func endedChallenges(page: Int, size: Int) -> Single<[EndedChallenge]>
}
