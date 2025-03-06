//
//  HomeUseCase.swift
//  UseCase
//
//  Created by jung on 10/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Entity

public protocol HomeUseCase {
  func fetchPopularChallenge() -> Single<[ChallengeDetail]>
  func fetchMyChallenges() -> Single<[ChallengeSummary]>
}
