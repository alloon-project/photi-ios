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

protocol ChallengeHomeCoordinatable: AnyObject {
  func authenticatedFailed()
  func requestNoneChallengeHome()
  func attachChallenge(id: Int)
  func attachChallengeWithFeed(challengeId: Int, feedId: Int)
}

protocol ChallengeHomeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ChallengeHomeCoordinatable? { get set }
}

enum UploadChallnegeFeedResult {
  case success(challengeId: Int, feedId: Int, url: URL?)
  case failure
}

final class ChallengeHomeViewModel: ChallengeHomeViewModelType {
  weak var coordinator: ChallengeHomeCoordinatable?
  private let disposeBag = DisposeBag()
  private let useCase: HomeUseCase
  private var firstJoinedChallengeId: Int?
  
  private let myChallengeFeedsRelay = BehaviorRelay<[MyChallengeFeedPresentationModel]>(value: [])
  private let myChallengesRelay = BehaviorRelay<[MyChallengePresentationModel]>(value: [])
  private let didUploadChallengeFeed = PublishRelay<UploadChallnegeFeedResult>()
  private let networkUnstableRelay = PublishRelay<String?>()
  private let fileTooLargeRelay = PublishRelay<Void>()
  private let alreadProveChallengeRelay = PublishRelay<Void>()

  // MARK: - Input
  struct Input {
    let viewDidAppear: Signal<Void>
    let requestData: Signal<Void>
    let didTapChallenge: Signal<Int>
    let uploadChallengeFeed: Signal<(Int, UIImageWrapper)>
    let didTapFeed: Signal<(challengeId: Int, feedId: Int)>
  }
  
  // MARK: - Output
  struct Output {
    let myChallengeFeeds: Driver<[MyChallengeFeedPresentationModel]>
    let myChallenges: Driver<[MyChallengePresentationModel]>
    let didUploadChallengeFeed: Signal<UploadChallnegeFeedResult>
    let networkUnstable: Signal<String?>
    let fileTooLarge: Signal<Void>
    let alreadProveChallenge: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: HomeUseCase, firstJoinedChallengeId: Int? = nil) {
    self.useCase = useCase
    self.firstJoinedChallengeId = firstJoinedChallengeId
  }
  
  func reloadData() {
    fetchInitialData()
  }
  
  func transform(input: Input) -> Output {
    input.viewDidAppear
      .emit(with: self) { owner, _ in
        guard let id = owner.firstJoinedChallengeId else { return }
        owner.coordinator?.attachChallenge(id: id)
        owner.firstJoinedChallengeId = nil
      }.disposed(by: disposeBag)
    
    input.requestData
      .emit(with: self) { owner, _ in
        owner.fetchInitialData()
      }
      .disposed(by: disposeBag)
    
    input.uploadChallengeFeed
      .emit(with: self) { owner, info in
        Task { await owner.uploadChallengeFeed(id: info.0, image: info.1) }
      }
      .disposed(by: disposeBag)
    
    input.didTapChallenge
      .emit(with: self) { owner, id in
        owner.coordinator?.attachChallenge(id: id)
      }
      .disposed(by: disposeBag)
    
    input.didTapFeed
      .emit(with: self) { owner, infos in
        owner.coordinator?.attachChallengeWithFeed(challengeId: infos.0, feedId: infos.1)
      }
      .disposed(by: disposeBag)
    
    return Output(
      myChallengeFeeds: myChallengeFeedsRelay.asDriver(),
      myChallenges: myChallengesRelay.asDriver(),
      didUploadChallengeFeed: didUploadChallengeFeed.asSignal(),
      networkUnstable: networkUnstableRelay.asSignal(),
      fileTooLarge: fileTooLargeRelay.asSignal(),
      alreadProveChallenge: alreadProveChallengeRelay.asSignal()
    )
  }
}

// MARK: - Fetch Methods
private extension ChallengeHomeViewModel {
  func fetchInitialData() {
    useCase.fetchMyChallenges()
      .observe(on: MainScheduler.instance)
      .subscribe(with: self) { owner, challenges in
        guard !challenges.isEmpty else {
          owner.coordinator?.requestNoneChallengeHome()
          return
        }
        
        let feedModels = owner.mapToMyChallengeFeeds(challenges)
        let challengeModels = owner.mapToMyChallenges(challenges)
        owner.myChallengeFeedsRelay.accept(feedModels)
        owner.myChallengesRelay.accept(challengeModels)
      } onFailure: { owner, error in
        owner.requestFailed(with: error)
      }
      .disposed(by: disposeBag)
  }
  
  func uploadChallengeFeed(id: Int, image: UIImageWrapper) async {
    do {
      let feed = try await useCase.uploadChallengeFeed(challengeId: id, image: image)
      didUploadChallengeFeed.accept(.success(challengeId: id, feedId: feed.id, url: feed.imageURL))
    } catch {
      didUploadChallengeFeed.accept(.failure)
      requestFailed(with: error, message: "네트워크가 불안정해, 챌린지 인증에 실패했어요.\n다시 시도해주세요.")
    }
  }
  
  func requestFailed(with error: Error, message: String? = nil) {
    guard let error = error as? APIError else { return networkUnstableRelay.accept(message) }
    
    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .challengeFailed(reason) where reason == .fileTooLarge:
        fileTooLargeRelay.accept(())
      case let .challengeFailed(reason) where reason == .alreadyUploadFeed:
        alreadProveChallengeRelay.accept(())
      default: networkUnstableRelay.accept(message)
    }
  }
  
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
    let model: MyChallengeFeedPresentationModel.ModelType
    
    if let id = challenge.feedId, challenge.isProve {
      model = .didProof(challenge.feedImageURL, feedId: id)
    } else {
      model = .didNotProof
    }
    
    return .init(
      challengeId: challenge.id,
      title: challenge.name,
      deadLine: proveTime,
      type: model
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
