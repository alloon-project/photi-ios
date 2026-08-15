//
//  ChallengeHomeViewModel.swift
//  HomeImpl
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Combine
import CoreUI
import Entity
import UseCase

protocol ChallengeHomeCoordinatable: AnyObject {
  @MainActor func attachChallenge(id: Int)
  @MainActor func attachChallengeWithFeed(challengeId: Int, feedId: Int)
  func authenticatedFailed()
  func requestNoneChallengeHome()
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
  private var cancellables = Set<AnyCancellable>()
  private let useCase: HomeUseCase
  private var firstJoinedChallengeId: Int?

  private let myChallengeFeedsSubject = CurrentValueSubject<[MyChallengeFeedPresentationModel], Never>([])
  private let myChallengesSubject = CurrentValueSubject<[MyChallengePresentationModel], Never>([])
  private let didUploadChallengeFeedSubject = PassthroughSubject<UploadChallnegeFeedResult, Never>()
  private let networkUnstableSubject = PassthroughSubject<String?, Never>()
  private let fileTooLargeSubject = PassthroughSubject<Void, Never>()
  private let alreadProveChallengeSubject = PassthroughSubject<Void, Never>()

  // MARK: - Input
  struct Input {
    let viewDidAppear: AnyPublisher<Void, Never>
    let requestData: AnyPublisher<Void, Never>
    let didTapChallenge: AnyPublisher<Int, Never>
    let uploadChallengeFeed: AnyPublisher<(Int, UIImageWrapper), Never>
    let didTapFeed: AnyPublisher<(challengeId: Int, feedId: Int), Never>
  }

  // MARK: - Output
  struct Output {
    let myChallengeFeeds: AnyPublisher<[MyChallengeFeedPresentationModel], Never>
    let myChallenges: AnyPublisher<[MyChallengePresentationModel], Never>
    let didUploadChallengeFeed: AnyPublisher<UploadChallnegeFeedResult, Never>
    let networkUnstable: AnyPublisher<String?, Never>
    let fileTooLarge: AnyPublisher<Void, Never>
    let alreadProveChallenge: AnyPublisher<Void, Never>
  }

  // MARK: - Initializers
  init(useCase: HomeUseCase, firstJoinedChallengeId: Int? = nil) {
    self.useCase = useCase
    self.firstJoinedChallengeId = firstJoinedChallengeId
  }

  func reloadData() {
    Task { await fetchInitialData() }
  }

  func transform(input: Input) -> Output {
    input.viewDidAppear
      .sinkOnMain(with: self) { owner, _ in
        guard let id = owner.firstJoinedChallengeId else { return }
        Task { await owner.coordinator?.attachChallenge(id: id) }
        owner.firstJoinedChallengeId = nil
      }
      .store(in: &cancellables)

    input.requestData
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.fetchInitialData() }
      }
      .store(in: &cancellables)

    input.uploadChallengeFeed
      .sinkOnMain(with: self) { owner, info in
        Task { await owner.uploadChallengeFeed(id: info.0, image: info.1) }
      }
      .store(in: &cancellables)

    input.didTapChallenge
      .sinkOnMain(with: self) { owner, id in
        Task { await owner.coordinator?.attachChallenge(id: id) }
      }
      .store(in: &cancellables)

    input.didTapFeed
      .sinkOnMain(with: self) { owner, infos in
        Task { await owner.coordinator?.attachChallengeWithFeed(challengeId: infos.0, feedId: infos.1) }
      }
      .store(in: &cancellables)

    return Output(
      myChallengeFeeds: myChallengeFeedsSubject.eraseToAnyPublisher(),
      myChallenges: myChallengesSubject.eraseToAnyPublisher(),
      didUploadChallengeFeed: didUploadChallengeFeedSubject.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher(),
      fileTooLarge: fileTooLargeSubject.eraseToAnyPublisher(),
      alreadProveChallenge: alreadProveChallengeSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Fetch Methods
private extension ChallengeHomeViewModel {
  func fetchInitialData() async {
    do {
      let challenges = try await useCase.fetchMyChallenges()
      guard !challenges.isEmpty else {
        self.coordinator?.requestNoneChallengeHome()
        return
      }
      let feedModels = mapToMyChallengeFeeds(challenges)
      let challengeModels = mapToMyChallenges(challenges)
      myChallengeFeedsSubject.send(feedModels)
      myChallengesSubject.send(challengeModels)
    } catch {
      requestFailed(with: error)
    }
  }

  func uploadChallengeFeed(id: Int, image: UIImageWrapper) async {
    do {
      guard
        let (imageData, type) = image.imageToData(maxMB: 8) else {
        throw APIError.challengeFailed(reason: .fileTooLarge)
      }
      let feed = try await useCase.uploadChallengeFeed(challengeId: id, imageData: imageData, type: type)
      didUploadChallengeFeedSubject.send(.success(challengeId: id, feedId: feed.id, url: feed.imageURL))
    } catch {
      didUploadChallengeFeedSubject.send(.failure)
      requestFailed(with: error, message: "네트워크가 불안정해, 챌린지 인증에 실패했어요.\n다시 시도해주세요.")
    }
  }

  func requestFailed(with error: Error, message: String? = nil) {
    guard let error = error as? APIError else { return networkUnstableSubject.send(message) }

    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .challengeFailed(reason) where reason == .fileTooLarge:
        fileTooLargeSubject.send(())
      case let .challengeFailed(reason) where reason == .alreadyUploadFeed:
        alreadProveChallengeSubject.send(())
      default: networkUnstableSubject.send(message)
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
