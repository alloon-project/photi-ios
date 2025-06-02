//
//  FeedHistoryViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol FeedHistoryCoordinatable: AnyObject {
  func didTapBackButton()
  func attachChallengeWithFeed(challengeId: Int, feedId: Int)
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
  private let requestFailedRelay = PublishRelay<Void>()
  
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
    let requestFailed: Signal<Void>
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
        owner.coordinator?.attachChallengeWithFeed(challengeId: id.challengeId, feedId: id.feedId)
      }
      .disposed(by: disposeBag)
    
    input.requestData
      .emit(with: self) { owner, _ in
        Task { await owner.loadFeedHistory() }
      }
      .disposed(by: disposeBag)
    
    return Output(
      feeds: feedsRelay.asDriver(),
      requestFailed: requestFailedRelay.asSignal()
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
      print(error)
      requestFailedRelay.accept(())
    }
  }
}

// MARK: - Private Methods
private extension FeedHistoryViewModel {
  func mapToFeedPresentationModel(_ feedHistory: FeedHistory) -> FeedCardPresentationModel {
    let date = feedHistory.createdDate.toString("yyyy. MM. dd 인증")
    return .init(
      challengeId: feedHistory.challengeId,
      feedId: feedHistory.feedId,
      feedImageUrl: feedHistory.imageUrl,
      challengeTitle: feedHistory.name,
      provedDate: date
    )
  }
}
