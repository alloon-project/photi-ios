//
//  FeedHistoryViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Combine
import CoreUI
import Foundation
import Entity
import UseCase

protocol FeedHistoryCoordinatable: AnyObject {
  @MainActor func attachChallengeWithFeed(challengeId: Int, feedId: Int)
  func didTapBackButton()
  func authenticateFailed()
}

protocol FeedHistoryViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FeedHistoryCoordinatable? { get set }
}

final class FeedHistoryViewModel: FeedHistoryViewModelType {
  weak var coordinator: FeedHistoryCoordinatable?
  private var cancellables = Set<AnyCancellable>()
  private let useCase: MyPageUseCase
  private var isFetching = false
  private var isLastPage = false
  private var currentPage = 0

  private let feedsRelay = CurrentValueSubject<[FeedCardPresentationModel], Never>([])
  private let requestOpenInsagramStoryRelay = PassthroughSubject<(URL?, String), Never>()
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()
  private let deletedChallengeRelay = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapFeed: AnyPublisher<(challengeId: Int, feedId: Int), Never>
    let didTapShareButton: AnyPublisher<(challengeId: Int, feedId: Int), Never>
    let requestData: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let feeds: AnyPublisher<[FeedCardPresentationModel], Never>
    let requestOpenInsagramStory: AnyPublisher<(URL?, String), Never>
    let deletedChallenge: AnyPublisher<Void, Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: MyPageUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .store(in: &cancellables)
    
    input.didTapFeed
      .sinkOnMain(with: self) { owner, id in
        owner.moveToFeedIfActive(challengeId: id.challengeId, feedId: id.feedId)
      }
      .store(in: &cancellables)
    
    input.requestData
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.loadFeedHistory() }
      }
      .store(in: &cancellables)
    
    input.didTapShareButton
      .sinkOnMain(with: self) { owner, info in
        guard let feedCard = owner.feedCard(challengeId: info.challengeId, feedId: info.feedId) else { return }
        
        owner.requestOpenInsagramStoryRelay.send((feedCard.feedImageUrl, feedCard.challengeTitle))
      }
      .store(in: &cancellables)
    
    return Output(
      feeds: feedsRelay.eraseToAnyPublisher(),
      requestOpenInsagramStory: requestOpenInsagramStoryRelay.eraseToAnyPublisher(),
      deletedChallenge: deletedChallengeRelay.eraseToAnyPublisher(),
      networkUnstable: networkUnstableRelay.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension FeedHistoryViewModel {
  func loadFeedHistory() async {
    guard !isLastPage && !isFetching else { return }
    
    isFetching = true
    
    defer {
      isFetching = false
      currentPage += 1
    }
      
    do {
      let result = try await useCase.loadFeedHistory(page: currentPage, size: 15)
      let models = result.values.map { mapToFeedPresentationModel($0) }
      feedsRelay.send(models)
      
      switch result {
        case .lastPage: isLastPage = true
        default: break
      }
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.send(()) }
    
    if case .authenticationFailed = error {
      coordinator?.authenticateFailed()
    } else {
      networkUnstableRelay.send(())
    }
  }
}

// MARK: - Private Methods
private extension FeedHistoryViewModel {
  func mapToFeedPresentationModel(_ feedHistory: FeedSummary) -> FeedCardPresentationModel {
    let date = feedHistory.createdDate.toString("yyyy. MM. dd 인증")
    return .init(
      challengeId: feedHistory.challengeId,
      feedId: feedHistory.feedId,
      feedImageUrl: feedHistory.imageUrl,
      challengeTitle: feedHistory.name,
      provedDate: date,
      isDeleted: feedHistory.isDeleted
    )
  }
  
  func feedCard(challengeId: Int, feedId: Int) -> FeedCardPresentationModel? {
    return feedsRelay.value.first { $0.challengeId == challengeId && $0.feedId == feedId }
  }
  
  func moveToFeedIfActive(challengeId: Int, feedId: Int) {
    guard let card = feedCard(challengeId: challengeId, feedId: feedId) else { return }
    
    if card.isDeleted {
      deletedChallengeRelay.send(())
    } else {
      Task { await coordinator?.attachChallengeWithFeed(challengeId: challengeId, feedId: feedId) }
    }
  }
}
