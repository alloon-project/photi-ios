//
//  FeedHistoryViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
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
  private let disposeBag = DisposeBag()
  private let useCase: MyPageUseCase
  private var isFetching = false
  private var isLastPage = false
  private var currentPage = 0

  private let feedsRelay = BehaviorRelay<[FeedCardPresentationModel]>(value: [])
  private let requestOpenInsagramStoryRelay = PublishRelay<(URL?, String)>()
  private let networkUnstableRelay = PublishRelay<Void>()
  private let deletedChallengeRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapFeed: Signal<(challengeId: Int, feedId: Int)>
    let didTapShareButton: Signal<(challengeId: Int, feedId: Int)>
    let requestData: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let feeds: Driver<[FeedCardPresentationModel]>
    let requestOpenInsagramStory: Signal<(URL?, String)>
    let deletedChallenge: Signal<Void>
    let networkUnstable: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: MyPageUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapFeed
      .emit(with: self) { owner, id in
        owner.moveToFeedIfActive(challengeId: id.challengeId, feedId: id.feedId)
      }
      .disposed(by: disposeBag)
    
    input.requestData
      .emit(with: self) { owner, _ in
        Task { await owner.loadFeedHistory() }
      }
      .disposed(by: disposeBag)
    
    input.didTapShareButton
      .emit(with: self) { owner, info in
        guard let feedCard = owner.feedCard(challengeId: info.challengeId, feedId: info.feedId) else { return }
        
        owner.requestOpenInsagramStoryRelay.accept((feedCard.feedImageUrl, feedCard.challengeTitle))
      }
      .disposed(by: disposeBag)
    
    return Output(
      feeds: feedsRelay.asDriver(),
      requestOpenInsagramStory: requestOpenInsagramStoryRelay.asSignal(),
      deletedChallenge: deletedChallengeRelay.asSignal(),
      networkUnstable: networkUnstableRelay.asSignal()
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
      feedsRelay.accept(models)
      
      switch result {
        case .lastPage: isLastPage = true
        default: break
      }
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.accept(()) }
    
    if case .authenticationFailed = error {
      coordinator?.authenticateFailed()
    } else {
      networkUnstableRelay.accept(())
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
      deletedChallengeRelay.accept(())
    } else {
      Task { await coordinator?.attachChallengeWithFeed(challengeId: challengeId, feedId: feedId) }
    }
  }
}
