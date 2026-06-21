//
//  FeedsByDateViewModel.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import Foundation
import CoreUI
import Entity
import UseCase

protocol FeedsByDateCoordinatable: AnyObject {
  @MainActor func attachChallengeWithFeed(challengeId: Int, feedId: Int)
  func didTapBackButton()
  func authenticateFailed()
}

protocol FeedsByDateViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FeedsByDateCoordinatable? { get set }
}

final class FeedsByDateViewModel: FeedsByDateViewModelType {
  weak var coordinator: FeedsByDateCoordinatable?
  private var cancellables = Set<AnyCancellable>()
  private let useCase: MyPageUseCase
  let date: Date
  
  private let feedsRelay = CurrentValueSubject<[FeedsByDatePresentationModel], Never>([])
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let requestData: AnyPublisher<Void, Never>
    let didTapFeed: AnyPublisher<(challengeId: Int, feedId: Int), Never>
  }
  
  // MARK: - Output
  struct Output {
    let feeds: AnyPublisher<[FeedsByDatePresentationModel], Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(date: Date, useCase: MyPageUseCase) {
    self.date = date
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .store(in: &cancellables)
    
    input.requestData
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.loadFeedsByDate() }
      }
      .store(in: &cancellables)
    
    input.didTapFeed
      .sinkOnMain(with: self) { owner, ids in
        Task { await owner.coordinator?.attachChallengeWithFeed(challengeId: ids.challengeId, feedId: ids.feedId) }
      }
      .store(in: &cancellables)
    
    return Output(
      feeds: feedsRelay.eraseToAnyPublisher(),
      networkUnstable: networkUnstableRelay.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension FeedsByDateViewModel {
  func loadFeedsByDate() async {
    let date = date.convertTimezone(from: .current, to: .kst).toString("YYYY-MM-dd")
    
    do {
      let feeds = try await useCase.loadFeeds(byDate: date)
      let models = feeds.map { mapToFeedsByDatePresentationModel($0) }
      
      feedsRelay.send(models)
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
private extension FeedsByDateViewModel {
  func mapToFeedsByDatePresentationModel(_ feed: FeedSummary) -> FeedsByDatePresentationModel {
    let provedTime = feed.proveTime.convertTimezone(from: .current, to: .kst)
      .toString("HH:mm")
    return .init(
      challengeId: feed.challengeId,
      feedId: feed.feedId,
      feedImageViewUrl: feed.imageUrl,
      title: feed.name,
      provedTime: provedTime
    )
  }
}
