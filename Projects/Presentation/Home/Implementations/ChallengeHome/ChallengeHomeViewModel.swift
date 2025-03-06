//
//  ChallengeHomeViewModel.swift
//  HomeImpl
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Core
import Entity
import UseCase

protocol ChallengeHomeCoordinatable: AnyObject { }

protocol ChallengeHomeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ChallengeHomeCoordinatable? { get set }
}

final class ChallengeHomeViewModel: ChallengeHomeViewModelType {
  weak var coordinator: ChallengeHomeCoordinatable?
  private let disposeBag = DisposeBag()
  private let useCase: HomeUseCase
  
  private let myChallengeFeedsRelay = BehaviorRelay<[MyChallengeFeedPresentationModel]>(value: [])
  private let myChallengesRelay = BehaviorRelay<[MyChallengePresentationModel]>(value: [])

  // MARK: - Input
  struct Input {
    let requestData: Signal<Void>
    let uploadChallengeFeed: Signal<(Int, UIImageWrapper)>
  }
  
  // MARK: - Output
  struct Output {
    let myChallengeFeeds: Driver<[MyChallengeFeedPresentationModel]>
    let myChallenges: Driver<[MyChallengePresentationModel]>
  }
  
  // MARK: - Initializers
  init(useCase: HomeUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.requestData
      .emit(with: self) { owner, _ in
        owner.fetchInitialData()
      }
      .disposed(by: disposeBag)
    
    return Output(
      myChallengeFeeds: myChallengeFeedsRelay.asDriver(),
      myChallenges: myChallengesRelay.asDriver()
    )
  }
}

// MARK: - Fetch Methods
private extension ChallengeHomeViewModel {
  func fetchInitialData() {
    useCase.fetchMyChallenges()
      .observe(on: MainScheduler.instance)
      .subscribe(with: self) { owner, challenges in
        let feedModels = owner.mapToMyChallengeFeeds(challenges)
        let challengeModels = owner.mapToMyChallenges(challenges)
        owner.myChallengeFeedsRelay.accept(feedModels)
        owner.myChallengesRelay.accept(challengeModels)
      } onFailure: { owner, error in
        owner.requestFailed(with: error)
      }
      .disposed(by: disposeBag)
  }
  
  func requestFailed(with error: Error) { }
  
  func mapToMyChallengeFeeds(_ challenges: [ChallengeSummary]) -> [MyChallengeFeedPresentationModel] {
    let didNotProofChallenges = challenges.filter { !$0.isProve }.sorted {
      ($0.proveTime ?? Date()) < ($1.proveTime ?? Date())
    }
    let didProofChallenges = challenges.filter { $0.isProve }.sorted {
      ($0.proveTime ?? Date()) < ($1.proveTime ?? Date())
    }
    
    var models = didNotProofChallenges.map { mapToMyChallengeFeed($0) }
    let didProofModels = didProofChallenges.map { mapToMyChallengeFeed($0) }
    models.append(contentsOf: didProofModels)
    
    return models
  }
  
  func mapToMyChallengeFeed(_ challenge: ChallengeSummary) -> MyChallengeFeedPresentationModel {
    let proveTime = challenge.proveTime?.toString("H시까지") ?? ""
    
    return .init(
      id: challenge.id,
      title: challenge.name,
      deadLine: proveTime,
      type: challenge.isProve ? .proof(url: challenge.feedImageURL) : .didNotProof
    )
  }
  
  func mapToMyChallenges(_ challenges: [ChallengeSummary]) -> [MyChallengePresentationModel] {
    return challenges.map {
      let proveTime = $0.proveTime?.toString("H:mm") ?? ""
      let endDate = $0.endDate.toString("YYYY.M.d")
      
      return .init(
        id: $0.id,
        title: $0.name,
        hashTags: $0.hashTags,
        imageUrl: $0.imageUrl,
        deadLineTime: proveTime,
        deadLineDate: endDate
      )
    }
  }
}
