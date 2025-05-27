//
//  SearchUseCase.swift
//  UseCase
//
//  Created by jung on 5/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity

public protocol SearchUseCase {
  func popularChallenges() -> Single<[ChallengeDetail]>
  func popularHashtags() -> Single<[String]>
}
